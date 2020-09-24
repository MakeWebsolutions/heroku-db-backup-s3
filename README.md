## Heroku Buildpack: heroku-db-backup-s3
Capture Postgress DB in Heroku and copy it to s3 bucket. Buildpack contains AWS CLI.

### Installation
Add buildpack to your Heroku app
```
heroku buildpacks:add https://github.com/MakeWebsolutions/heroku-db-backup-s3 --app <your_app>
```
> Buildpacks are scripts that are run when your app is deployed.

### Configure environment variables
```
heroku config:add AWS_ACCESS_KEY_ID=someaccesskey --app <your_app>
heroku config:add AWS_SECRET_ACCESS_KEY=supermegasecret --app <your_app>
heroku config:add AWS_REGION=eu-central-1 --app <your_app>
heroku config:add BACKUP_S3_BUCKET=your-bucket --app <your_app>
```

### Scheduler
Add addon scheduler to your app. 
```
heroku addons:create scheduler --app <your_app>
```
Create scheduler.
```
heroku addons:open scheduler --app <your_app>
```

Script:
bash /app/vendor/backup.sh -db <somedbname>
