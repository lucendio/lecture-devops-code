#!/usr/bin/env bash



readonly SELF_DIR="$(cd $(dirname ${0}) && pwd)"


readonly DEBUG_ENABLED=false
readonly VERBOSE_ENABLED=false

readonly AWSACADEMY_ROOT_DOMAIN='www.awsacademy.com'
readonly AWSACADEMY_INSTRUCTURE_ROOT_URL='https://awsacademy.instructure.com'
readonly AWSACADEMY_INSTRUCTURE_TEACHER_LOGIN_URL="${AWSACADEMY_INSTRUCTURE_ROOT_URL}/login/saml"
readonly AWSACADEMY_INSTRUCTURE_STUDENT_LOGIN_URL="${AWSACADEMY_INSTRUCTURE_ROOT_URL}/login/canvas"
readonly AWSACADEMY_LOGIN_FORM_NAME='loginPage:siteLogin:loginComponent:loginForm'
readonly AWS_CREDENTIALS_PATH="${1:-"${SELF_DIR}/creds"}"

readonly CURL_REQUIRED_OPTIONS=(
    --cookie "${SELF_DIR}/cookie-store.txt"
    --cookie-jar "${SELF_DIR}/cookie-store.txt"
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


if [ -f "${SELF_DIR}/user.vars" ]; then
    source "${SELF_DIR}/user.vars"
fi

[ -z "${user}" ] && read -p " AWS Academy Username: " user
[ -z "${pw}" ] && read -s -p " Password: " pw
if [ -z "${role}" ]; then
    while true; do
        read -p " Role: student (default) or teacher? [sS/tT]: " role
        case ${role} in
            [sS]* ) role=student; break;;
            [eE]* ) role=teacher; break;;
            * ) role=student; break;;
        esac
    done
fi
echo ""


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

function extractFullFormId(){
    local stringIn=$1
    local formIdPart=$2
    local result=$( \
        echo "${stringIn}" \
        | xmllint \
            --xpath "string(//script[contains(@id,'${formIdPart}')]/@id)" \
            --html \
            - 2>/dev/null \
    )
    echo ${result}
}


function extractHref(){
    local stringIn=$1
    local result=$( \
        echo "${stringIn}" \
        | grep 'location.href' \
        | sed "s/.*'\(.*\)'.*$/\1/" \
    )
    echo ${result}
}


function extractHiddenInputNameAndValue() {
    local stringIn=$1

    local -r inputName=$(echo "${stringIn}" | xmllint --xpath "string(//input[@type='hidden']/@name)" --html - 2>/dev/null)
    local -r inputValue=$(echo "${stringIn}" | xmllint --xpath "string(//input[@type='hidden']/@value)" --html - 2>/dev/null)

    echo "${inputName} ${inputValue}"
}

function extractCourseId() {
    local stringIn=$1
    local courseName=$2

    local -r href=$(echo "${stringIn}" | xmllint --xpath "string(//table[@id='my_courses_table']//a[contains(@title,'${courseName}')]/@href)" --html - 2>/dev/null)
    local -r courseId=$(echo "${href}" | awk -F '/' '{print $3}')

    echo "${courseId}"
}

function extractModulePath() {
    local stringIn=$1
    local moduleTitle=$2

    local -r hrefValue=$(echo "${stringIn}" | xmllint --xpath "string(//a[@title='${moduleTitle}']/@href)" --html - 2>/dev/null)

    echo "${hrefValue}"
}

function checkIfLoggedIn() {
    (${DEBUG_ENABLED} && echo " [DEBUG] Checking if being logged in")
    local -r response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${AWSACADEMY_INSTRUCTURE_ROOT_URL}" \
    )

    #echo "${response}" | grep -q "${AWSACADEMY_INSTRUCTURE_TEACHER_LOGIN_URL}"
    #local -r teacher=$?
    #echo "${response}" | grep -q "${AWSACADEMY_INSTRUCTURE_STUDENT_LOGIN_URL}"
    #local -r student=$?
    echo "${response}" | grep -p 'user authorization required'
    local -r status=$?
    if [[ "${status}" -eq "0" ]]; then
        return 1
    else
        return 0
    fi
}


function getLabStatus() {
    local -r key=$1
    local -r step=$2

    local -r statusURL="https://labs.vocareum.com/util/vcput.php?a=getawsstatus&stepid=${step}&version=0&mode=s&type=1&vockey=${key}"

    (${DEBUG_ENABLED} && echo " [DEBUG] Checking Lab status")
    local -r response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${credentialsURL}" \
    )
    local -r returnCode=$?

    case "${response}" in
        *creation* )
            echo 'starting'
        ;;
        *ready* )
            echo 'up'
        ;;
        *stopped* )
            echo 'down'
        ;;
        * )
            echo 'unsupported'
        ;;
    esac
}


function startLab() {
    local -r key=$1
    local -r step=$2

    local -r startURL="https://labs.vocareum.com/util/vcput.php?a=startaws&stepid=${step}&version=0&mode=s&type=1&vockey=${key}"

    (${DEBUG_ENABLED} && echo " [DEBUG] Starting Lab")
    local -r response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${credentialsURL}" \
    )
    local -r returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/10_StartLab.log.json")

    if cat "${response}" | grep -q 'success'; then
        return 0;
    else
        echo " [ERROR] Failed to start Lab" >&2
        exit 1
    fi
}


function stopLab() {
    local -r key=$1
    local -r step=$2

    local -r startURL="https://labs.vocareum.com/util/vcput.php?a=endaws&stepid=${step}&version=0&mode=s&type=1&vockey=${key}"

    (${DEBUG_ENABLED} && echo " [DEBUG] Stopping Lab")
    local -r response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${credentialsURL}" \
    )
    local -r returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/11_StopLab.log.json")

    if cat "${response}" | grep -q 'success'; then
        return 0;
    else
        echo " [ERROR] Failed to stop Lab" >&2
        exit 1
    fi
}


function obtainAWSCredentials() {
    local -r key=$1
    local -r step=$2

    local -r credentialsURL="https://labs.vocareum.com/util/vcput.php?a=getaws&type=1&stepid=${step}&version=0&v=0&vockey=${key}"

    local -r response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${credentialsURL}" \
    )
    local -r returnCode=$?

    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/09_obtainAWSCredentials.log.txt")

    local -r keyId=$(extractValue "${response}" 'aws_access_key_id')
    local -r accessKey=$(extractValue "${response}" 'aws_secret_access_key')
    local -r sessionToken=$(extractValue "${response}" 'aws_session_token')

    echo "${keyId} ${accessKey} ${sessionToken}"
}



# TODO: instead of flushing the session everytime the script runs,
#       check whether user is still logged in; if so, skip login
#
if [ -f "${SELF_DIR}/cookie-store.txt" ]; then
    echo " [INFO] Flushing cookie store"
    rm -rf "${SELF_DIR}/cookie-store.txt"
fi



if [[ "${role}" == "teacher" ]]; then

    (${DEBUG_ENABLED} && echo " [DEBUG] Opening AWS Academy sign in page")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${AWSACADEMY_INSTRUCTURE_TEACHER_LOGIN_URL}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/00_openSignInPage.log.html")



    viewState=$(extractHiddenInputValue "${response}" 'com.salesforce.visualforce.ViewState')
    viewStateMAC=$(extractHiddenInputValue "${response}" 'com.salesforce.visualforce.ViewStateMAC')
    viewStateVersion=$(extractHiddenInputValue "${response}" 'com.salesforce.visualforce.ViewStateVersion')
    formSubmitUrl=$(echo "${response}" | xmllint --xpath "string(//form[@name='${AWSACADEMY_LOGIN_FORM_NAME}']/@action)" --html - 2>/dev/null)
    if [[ -z "${viewState}" ]] || [[ -z "${viewStateMAC}" ]] || [[ -z "${viewStateVersion}" || -z "${formSubmitUrl}" ]]; then
        echo " [ERROR] ViewState variables are empty" >&2
        exit 1
    fi

    echo " [INFO] Logging in"
    (${DEBUG_ENABLED} && echo " [DEBUG] Signing in to AWS Academy")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request POST \
            \
            --data-urlencode "${AWSACADEMY_LOGIN_FORM_NAME}=${AWSACADEMY_LOGIN_FORM_NAME}" \
            --data-urlencode "${AWSACADEMY_LOGIN_FORM_NAME}:loginButton=Login" \
            --data-urlencode "${AWSACADEMY_LOGIN_FORM_NAME}:username=${user}" \
            --data-urlencode "${AWSACADEMY_LOGIN_FORM_NAME}:password=${pw}" \
            \
            --data-urlencode "com.salesforce.visualforce.ViewState=${viewState}" \
            --data-urlencode "com.salesforce.visualforce.ViewStateMAC=${viewStateMAC}" \
            --data-urlencode "com.salesforce.visualforce.ViewStateVersion=${viewStateVersion}" \
            \
            "${formSubmitUrl}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/01_SiteLogin.log.html")



    # ASSERT: <htm<head><script> [...]\n window.location.href ='https://www.awsacademy.com/secur/frontdoor.jsp...'; [...]</script></head></html>
    readonly redirectUrl=$(extractHref "${response}")
    if [[ -z "${redirectUrl}" ]]; then
        echo " [ERROR] Sign in redirect URL is empty" >&2
        echo " [HINT] Your login data may be wrong"
        exit 1
    fi

    (${DEBUG_ENABLED} && echo " [DEBUG] Following sign-in redirect")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            "${redirectUrl}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/02_SigninRedirect.log.html")



    # ASSERT: <htm<head><script> [...]\n window.location.href ='/idp/login?app=...'; [...]</script></head></html>
    readonly redirectPath=$(extractHref "${response}")
    if [[ -z "${redirectPath}" ]]; then
        echo " [ERROR] IDP login redirect path is empty" >&2
        echo " [HINT] Path extraction may have failed"
        exit 1
    fi

    (${DEBUG_ENABLED} && echo " [DEBUG] Following Communities Landing redirect")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            "https://${AWSACADEMY_ROOT_DOMAIN}${redirectPath}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/03_IdpLoginRedirect.log.html")



    read inputName inputValue <<< $(extractHiddenInputNameAndValue "${response}")
    if [[ -z "${inputName}" ]] || [[ -z "${inputValue}" ]]; then
        echo " [ERROR] SAML credentials are empty" >&2
        exit 1
    fi

    (${DEBUG_ENABLED} && echo " [DEBUG] Logging in into Instructure with credentials")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request POST \
            \
            --data-urlencode "${inputName}=${inputValue}" \
            \
            "${AWSACADEMY_INSTRUCTURE_TEACHER_LOGIN_URL}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/04_InstructureSamlLogin.log.html")

fi



if [[ "${role}" == "student" ]]; then

    (${DEBUG_ENABLED} && echo " [DEBUG] Opening AWS Academy sign in page")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            "${AWSACADEMY_INSTRUCTURE_STUDENT_LOGIN_URL}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/00_openSignInPage.log.html")



    authenticityToken=$(extractHiddenInputValue "${response}" 'authenticity_token')
    if [[ -z "${authenticityToken}" ]]; then
        echo " [ERROR] authenticityToken variable is empty" >&2
        exit 1
    fi

    echo " [INFO] Logging in"
    (${DEBUG_ENABLED} && echo " [DEBUG] Signing in to AWS Academy")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request POST \
            \
            --data-urlencode "authenticity_token=${authenticityToken}" \
            --data-urlencode "pseudonym_session[unique_id]=${user}" \
            --data-urlencode "pseudonym_session[password]=${pw}" \
            \
            --data-urlencode "utf8=✓" \
            --data-urlencode "redirect_to_ssl=1" \
            --data-urlencode "pseudonym_session[remember_me]=0" \
            \
            "${AWSACADEMY_INSTRUCTURE_STUDENT_LOGIN_URL}" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/01_SiteLogin.log.html")

fi



if checkIfLoggedIn; then
    (${DEBUG_ENABLED} && echo " [DEBUG] User is logged in")
else
    echo " [ERROR] Login is supposed to be valid, but it's not" >&2
    exit 1
fi



if [[ -z "${course}" ]]; then
    (${DEBUG_ENABLED} && echo " [DEBUG] Opening courses page")
    response=$( \
        curl \
            "${CURL_OPTIONS[@]}" \
            --request GET \
            \
            "https://awsacademy.instructure.com/courses" \
    )
    returnCode=$?
    (${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/05_CoursesPage.log.html")

    echo " [INFO] Determining course ID since it's not being set manually"

    read course <<< $(extractCourseId "${response}" 'AWS Academy Learner Lab - Foundation Services')
    if [[ -z "${course}" ]]; then
        echo " [ERROR] course ID is empty" >&2
        exit 1
    fi
fi



(${DEBUG_ENABLED} && echo " [DEBUG] Opening modules page")
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        --request GET \
        \
        "https://awsacademy.instructure.com/courses/${course}/modules" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/06_ModulesPage.log.html")




read modulePath <<< $(extractModulePath "${response}" 'Learner Lab - Foundational Services')
if [[ -z "${modulePath}" ]]; then
    echo " [ERROR] Module path is empty" >&2
    exit 1
fi

(${DEBUG_ENABLED} && echo " [DEBUG] Opening Learner Lab module page")
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        --request GET \
        \
        "https://awsacademy.instructure.com/${modulePath}" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/07_LearnerLabPage.log.html")



readonly vocareumFormUrl=$(echo "${response}" \
    | xmllint \
        --xpath "string(//form[@id='tool_form']/@action)" \
        --html \
    - 2>/dev/null \
)
readonly inputCount=$( \
    echo "${response}" \
        | xmllint \
            --xpath 'count(//form[@id="tool_form"]/input[@type="hidden"])' \
            --html \
        - 2>/dev/null \
)
formData=()
for (( i=1; i<=${inputCount}; i++ )); do
    inputName=$(echo "${response}" \
    | xmllint \
        --xpath "string(//form[@id='tool_form']/input[@type='hidden' and position()=${i}]/@name)" \
        --html \
    - 2>/dev/null)
    inputValue=$(echo "${response}" \
    | xmllint \
        --xpath "string(//form[@id='tool_form']/input[@type='hidden' and position()=${i}]/@value)" \
        --html \
    - 2>/dev/null)

    formData+=('--data-urlencode')
    formData+=("${inputName}=${inputValue}")
done

(${DEBUG_ENABLED} && echo " [DEBUG] Submitting Vocareum form")
response=$( \
    curl \
        "${CURL_OPTIONS[@]}" \
        --request POST \
        \
        "${formData[@]}" \
        \
        "${vocareumFormUrl}" \
)
returnCode=$?
(${VERBOSE_ENABLED} && echo "${response}" > "${SELF_DIR}/08_VocareumFormSubmit.log.html")



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

readonly stepId=$(echo "${response}" | grep -m 1 'stepid' | tr '&' '\n' | grep 'stepid' | sed 's/.*=\(.*\)*$/\1/')
if [[ -z "${stepId}" ]]; then
    echo " [ERROR] stepId is empty" >&2
    exit 1
fi


echo " [INFO] Checking Lab status"
read labStatus <<< $(getLabStatus "${accessProviderKey}" "${stepId}")

if [[ "${labStatus}" == 'down' ]]; then
    echo " [INFO] Starting Lab"
    startLab "${accessProviderKey}" "${stepId}"
elif [[ "${labStatus}" == 'up' ]]; then
    # TODO: check when session expires
    echo " [INFO] Renewing Lab session"
    startLab "${accessProviderKey}" "${stepId}"
fi

attempts=1
while [ "${labStatus}" != 'up' ] && [ "${attempts}" -lt 5 ]; do
    read labStatus <<< $(getLabStatus "${accessProviderKey}" "${stepId}")
    sleep 2
    attempts=$((attempts + 1))
done


echo " [INFO] Requesting AWS credentials"
read keyId accessKey sessionToken <<< $(obtainAWSCredentials "${accessProviderKey}" "${stepId}")

echo " [INFO] Writing credentials to file: ${credentialsPath:-${AWS_CREDENTIALS_PATH}}"
mkdir -p $(dirname ${credentialsPath:-${AWS_CREDENTIALS_PATH}})
cat <<- EOF > "${credentialsPath:-${AWS_CREDENTIALS_PATH}}"
	[default]
	aws_access_key_id = ${keyId}
	aws_secret_access_key = ${accessKey}
	aws_session_token = ${sessionToken}
EOF

echo ""
