12 - Create an encrypted backup 
===============================


### Solution

*Please note that this solution is based on AWS S3 buckets.*


#### (0) Preparations

Ensure that the tool chain is installed:

* AWS CLI
* Terraform
* [OpenSSL](https://www.openssl.org/) (alt. [LibreSSL](https://www.libressl.org)) a/o [GnuPG](https://gnupg.org/) (alt. [Sequoia-PGP](https://sequoia-pgp.org/))


#### (1) Allocate external Object Storage

Use Terraform to create an S3 bucket.

*__NOTE:__ Please refer to previous tutorials for how to manage infrastructure resources with Terraform*

*__NOTE:__ Alternatively, you may create a bucket with the AWS CLI*

Verify that the bucket exists:
```
aws s3 ls
```


#### (2) Create a backup, encrypt it and store it remotely

1. Create a backup archive file

```
export TEMP_DIR=$(mktemp -d)
cp ./* ${TEMP_DIR}/
tar --create --gzip --file ./backup.tar.gz --directory ${TEMP_DIR} .
rm -r ${TEMP_DIR}
unset TEMP_DIR
```

2. Encrypt the backup file

*__NOTE:__ Use `openssl` for symmetric or `gpg` for asymmetric encryption*

2a) Encrypt symmetrically
```
# INFO: will ask you to enter the symmetric key (password)
openssl enc -aes-256-cbc -salt -in ./backup.tar.gz -out ./backup.tar.gz.enc
```

2b) Generate a key pair (in case you don't already have a GPG key-pair) and encrypt asymmetrically
```
# INFO: will ask you to initially set a passphrase
gpg --batch --gen-key ./gpg-key.conf
```
```
export OWN_KEY_FINGERPRINT=$(gpg --with-colons --fingerprint | grep fpr | head -n 1 | awk -F ':' '{print $10}')
gpg --encrypt --recipient ${OWN_KEY_FINGERPRINT} --output ./backup.tar.gz.enc ./backup.tar.gz
```

3. Upload the backup to a bucket

```
export BUCKET_NAME=$(terraform output -raw 'advancedBucketName')
aws s3 cp ./backup.tar.gz.enc s3://${BUCKET_NAME}
aws s3 ls s3://${BUCKET_NAME}
rm ./backup.tar.gz.enc
```


#### (3) Restore data from the backup

1. Choose and download the backup you want to restore

```
aws s3 cp s3://${BUCKET_NAME}/backup.tar.gz.enc ./
```

2. Decrypt the backup file

*__NOTE:__ Use `openssl` for symmetric or `gpg` for asymmetric decryption*

2a) Decrypt symmetrically
```
# INFO: will ask you again to enter the symmetric key (password)
openssl enc -aes-256-cbc -salt -d -in ./backup.tar.gz.enc -out ./backup.tar.gz
```

2b) Decrypt asymmetrically

```
# INFO: may ask you to enter your passphrase (depending on your cache TTL)
gpg --decrypt --output ./backup.tar.gz ./backup.tar.gz.enc
```

3. Decompress the archive content

```
mkdir -p ./backup && tar --extract --gzip --file ./backup.tar.gz --directory ./backup
```

4. Verify the result

```
ls -al ./backup
```

5. Don't forget to clean up at the end

```
terraform destroy -auto-approve
rm -r ./backup.tar.gz.enc ./backup.tar.gz ./backup
```
