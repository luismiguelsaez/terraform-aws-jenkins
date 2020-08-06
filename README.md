## Create python virtualenv ( optional )
```
$ virtualenv -p /usr/bin/python3 .venv
$ . .venv/bin/activate
$ pip install -r requirements.txt
```

## Setup ansible credentials

### Create credentials
```
$ aws configure
```

### Check credentials
```
$ cat ~/.aws/credentials 

[default]
aws_access_key_id = AKIA****
aws_secret_access_key = ****

$ cat ~/.aws/config 

[default]
region = eu-west-1
output = json
```

## Setup ansible roles
```
$ ansible-galaxy install --force -r requirements.yml
```

## Deployment steps
```
$ ansible-playbook playbooks/00-create.yml
```
