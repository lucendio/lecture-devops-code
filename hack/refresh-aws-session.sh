#!/usr/bin/env bash

set -o pipefail



readonly DEBUG_ENABLED=true
readonly VERBOSE_ENABLED=false

readonly AWSEDUCATE_SIGNIN_URL="https://www.awseducate.com/signin/SiteLogin"
readonly CREDENTIALS_PATH='./creds'

readonly CURL_REQUIRED_OPTIONS=(
    --cookie ./cookie-store.txt
    --cookie-jar ./cookie-store.txt
    --location
    --header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36'
    --silent
)

if ${VERBOSE_ENABLED}; then
    readonly CURL_OPTIONS=(
        "${CURL_REQUIRED_OPTIONS[@]}"
        --verbose
    )
else
    readonly CURL_OPTIONS=(
        "${CURL_REQUIRED_OPTIONS[@]}"
    )
fi


function filterOutLeadingAndTrialingHiddenCharacters() {
    local stringIn=$1
    local result=$(echo "${stringIn}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    echo ${result}
}

function extractValue() {
    local stringIn=$1
    local searchKey=$2
    local value=$(echo "${stringIn}" | grep "${searchKey}" | awk -F '=' '{print $2}')
    echo $(filterOutLeadingAndTrialingHiddenCharacters ${value})
}

function extractHiddenInputValue(){
    local stringIn=$1
    local name=$2
    local result=$( \
        echo "${stringIn}" \
        | xmllint \
            --xpath "string(//input[@type='hidden' and @name='${name}']/@value)" \
            --html \
            - 2>/dev/null \
    )
    echo ${result}
}


function obtainAWSCredentials() {
    local -r key=$1

    local -r credentialsURL="https://labs.vocareum.com/util/vcput.php?a=getaws&type=0&stepid=14335&v=1&vockey=${key}"

    (${DEBUG_ENABLED} && echo " [DEBUG] Requesting credentials" >&2)

    local -r response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${credentialsURL}" \
    )
    local -r returnCode=$?

    (${VERBOSE_ENABLED} && echo "${response}" > ./07_obtainAWSCredentials.log.txt)

    local -r keyId=$(extractValue "${response}" 'aws_access_key_id')
    local -r accessKey=$(extractValue "${response}" 'aws_secret_access_key')
    local -r sessionToken=$(extractValue "${response}" 'aws_session_token')

    echo "${keyId} ${accessKey} ${sessionToken}"
}



read -p " AWS Educate Username: " user
read -s -p " Password: " pw
echo ""



echo " [INFO] Flushing cookie store..."
rm -rf ./cookie-store.txt



(${DEBUG_ENABLED} && echo " [DEBUG] Opening AVS Educate sign in page" >&2)
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        --request GET \
        "${AWSEDUCATE_SIGNIN_URL}" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > ./00_openSigninPage.log.html)



viewState=$(extractHiddenInputValue "${response}" 'com.salesforce.visualforce.ViewState')
viewStateMAC=$(extractHiddenInputValue "${response}" 'com.salesforce.visualforce.ViewStateMAC')
viewStateVersion=$(extractHiddenInputValue "${response}" 'com.salesforce.visualforce.ViewStateVersion')
if [[ -z "${viewState}" ]] || [[ -z "${viewState}" ]] || [[ -z "${viewState}" ]]; then
    echo " [ERROR] ViewState variables are empty" >&2
    exit 1
fi

(${DEBUG_ENABLED} && echo " [DEBUG] Signing in to AVS Educate" >&2)
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        --request POST \
        \
        --data-urlencode 'AJAXREQUEST=_viewRoot' \
        --data-urlencode 'loginPage:siteLogin:loginComponent:loginForm:j_id10=loginPage:siteLogin:loginComponent:loginForm:j_id10' \
        \
        --data-urlencode 'loginPage:siteLogin:loginComponent:loginForm=loginPage:siteLogin:loginComponent:loginForm' \
        --data-urlencode "loginPage:siteLogin:loginComponent:loginForm:username=${user}" \
        --data-urlencode "loginPage:siteLogin:loginComponent:loginForm:password=${pw}" \
        \
        --data-urlencode "com.salesforce.visualforce.ViewState=${viewState}" \
        --data-urlencode "com.salesforce.visualforce.ViewStateMAC=${viewStateMAC}" \
        --data-urlencode "com.salesforce.visualforce.ViewStateVersion=${viewStateVersion}" \
        \
        "${AWSEDUCATE_SIGNIN_URL}?refURL=http://www.awseducate.com/signin/SiteLogin" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > ./01_SiteLogin.log.xml)



# ASSERT: <html xmlns="http://www.w3.org/1999/xhtml"><head><meta name="Ajax-Response" content="redirect" /><meta name="Location" content="https://www.awseducate.com/signin/secur/frontdoor.jsp?..." /></head></html>
readonly redirectURL=$(echo "${response}" | xmllint --xpath "string(//meta[@name='Location']/@content)" --html - 2>/dev/null)
if [[ -z "${redirectURL}" ]]; then
    echo " [ERROR] Sign in redirect URL is empty" >&2
    exit 1
fi

(${DEBUG_ENABLED} && echo " [DEBUG] Following sign-in redirect" >&2)
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        "${redirectURL}" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > ./02_SigninRedirect.log.html)



(${DEBUG_ENABLED} && echo " [DEBUG] Going to AWS Educate Starter account site (AWS Account)" >&2)
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        "https://www.awseducate.com/educator/s/awssite" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > ./03_awsStarterAccountSite.log.html)



auraToken=$(echo "${response}" | grep 'var auraConfig' | tr ',' '\n' | grep token | sed 's/.*"\(.*\)"[^"]*$/\1/')
if [[ -z "${auraToken}" ]]; then
    echo " [ERROR] aura token is empty" >&2
    exit 1
fi

# NOTE: meaning and origin yet to be known
readonly STATIC_FWUID='dDIdorNC3N22LalQ5i3slQ'

readonly randomNapiliAppValue=$(LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 22 | head -n 1)
readonly requestParamsForCredentials='r=1&other.StudentPageAWSAccount.getAWSSiteWrapper=1'
readonly auraContext=$(cat <<- EOM
{
    "mode": "PROD",
    "fwuid": "${STATIC_FWUID}",
    "app": "siteforce:napiliApp",
    "loaded": {
        "APPLICATION@markup://siteforce:napiliApp":"${randomNapiliAppValue}"
    },
    "dn": [],
    "globals": {},
    "uad": false
}
EOM
)

(${DEBUG_ENABLED} && echo " [DEBUG] Requesting access provider SSO URL" >&2)
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        --request POST \
        \
        --data-urlencode "aura.context=${auraContext}" \
        --data-urlencode "aura.token=${auraToken}" \
        --data-urlencode 'aura.pageURI=/educator/s/awssite' \
        --data-urlencode 'message={"actions":[{"id":"1;a","descriptor":"apex://StudentPageAWSAccountController/ACTION$getAWSSiteWrapper","callingDescriptor":"markup://c:awsAccount","params":{}}]}' \
        \
        "https://www.awseducate.com/educator/s/sfsites/aura?${requestParamsForCredentials}" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > ./04_awsAccessProviderUrl.log.json)



readonly awsAccessProviderSSOUrl=$(echo "${response}" | tr ',' '\n' | grep postTo | sed 's/.*"\(.*\)"[^"]*$/\1/')
if [[ -z "${awsAccessProviderSSOUrl}" ]]; then
    echo " [ERROR] AWS access provider URL empty" >&2
    exit 1
fi

(${DEBUG_ENABLED} && echo " [DEBUG] Invoking AWS Educate access provider SSO URL" >&2)
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        "${awsAccessProviderSSOUrl}" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > 05_awsAccessProviderResponse.log.xml)



# ASSERT: res='<script>window.location="https://labs.vocareum.com/main/main.php?m=editor&nav=1&asnid=...&stepid=...&redirect=1&token=...";</script'
# Check whether already being logged in or not yet
if echo "${response}" | grep -q '<script>window.location'; then

    # echo $res | awk -F '"' '{print $2}'
    # OR
    # echo $res | sed 's/^.*"\(.*\)".*/\1/'
    #                               extract from script         remove padded newline
    forwardURL=$(echo ${response} | sed 's/^.*"\(.*\)".*/\1/' | sed -e 's/^\r//g' )

    (${DEBUG_ENABLED} && echo " [DEBUG] Following access provider forward URL" >&2)
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            "${forwardURL}" \
    )
    returnCode=$?
    (${DEBUG_ENABLED} && echo "${response}" > 06_accessProverForward.log.html)

elif echo "${response}" | grep -q 'Access denied:SSO token expired'; then
    echo " [ERROR] AWS account session expired. Abort!" >&2
    exit 1
else
    echo " [INFO] still logged in to access provider" >&2
fi



# ASSERT: one single line containing 'var csrfToken = {...}'
readonly line="$(echo "${response}" | grep 'var csrfToken')"
returnCode=$?
if [[ "${returnCode}" != "0" ]]; then
    echo " [ERROR] Assertion not correct anymore" >&2
    exit 1
fi

readonly accessProviderKey="$(echo "${line}" | sed 's/^.*"\(.*\)".*/\1/')"
if [[ -z "${accessProviderKey}" ]]; then
    echo " [ERROR] accessProviderKey is empty" >&2
    exit 1
fi

read keyId accessKey sessionToken < <(obtainAWSCredentials "${accessProviderKey}")

(${DEBUG_ENABLED} && echo " [DEBUG] Writing credentials to file: ${CREDENTIALS_PATH}" >&2)
cat <<- EOF > "${CREDENTIALS_PATH}"
	[default]
	aws_access_key_id = ${keyId}
	aws_secret_access_key = ${accessKey}
	aws_session_token = ${sessionToken}
EOF
