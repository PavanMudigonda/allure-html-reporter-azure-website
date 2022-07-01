| **Reporter**        | **Github Pages**   | **Azure Storage Static Website** | **AWS S3 Static Website**                                                                    |
|---------------------|--------------------|-------------------------------|----------------------------------------------------------------------------------------------|
| **Allure HTML**     | [GH Action Link](https://github.com/marketplace/actions/allure-html-reporter-github-pages) | [GH Action Link](https://github.com/marketplace/actions/allure-html-reporter-azure-website)            | [GH Action Link](https://github.com/marketplace/actions/allure-html-reporter-aws-s3-website )      |
| **Any HTML Reports** | [GH Action Link](https://github.com/marketplace/actions/html-reporter-github-pages) | [GH Action Link](https://github.com/marketplace/actions/html-reporter-azure-website)            | [GH Action Link](https://github.com/marketplace/actions/html-reporter-aws-s3-website) |



Example workflow file [allure-html-reporter-azure-blob-website](https://github.com/PavanMudigonda/allure-html-reporter-azure-website/blob/main/.github/workflows/main.yml))

# Allure HTML Test Results on AWS S3 Bucket with history action

## Usage

### `main.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)


#### The following example includes optimal defaults for a public static website:

```yaml
name: test-results

on:
  push:
    branches:
    - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Create Test Results History
        uses: PavanMudigonda/allure-html-reporter-azure-website@v1.0
        with:
          allure_results: allure-results
          allure_history: allure-history
          allure_report: allure-report
          keep_reports: 15
          account_name: ${{ secrets.ACCOUNT_NAME }}
          container: ${{ secrets.CONTAINER }}
          SAS: ${{ secrets.SAS }}
```


## Also you can post link to the report to MS Teams
```yaml

- name: Message MS Teams Channel
  uses: toko-bifrost/ms-teams-deploy-card@master
  with:
    github-token: ${{ github.token }}
    webhook-uri: ${{ secrets.MS_TEAMS_WEBHOOK_URI }}
    custom-facts: |
      - name: Github Actions Test Results
        value: "http://example.com/${{ github.run_id }}"
    custom-actions: |
      - text: View CI Test Results
        url: "https://PavanMudigonda.github.io/html-reporter-github-pages/${{ github.run_number }}"
 ```
 
 ## Also you can post link to the report to MS Outlook
 
 ```yaml
 
 
 - name: Send mail
  uses: dawidd6/action-send-mail@v3
  with:
    # Required mail server address:
    server_address: smtp.gmail.com
    # Required mail server port:
    server_port: 465
    # Optional (recommended): mail server username:
    username: ${{secrets.MAIL_USERNAME}}
    # Optional (recommended) mail server password:
    password: ${{secrets.MAIL_PASSWORD}}
    # Required mail subject:
    subject: Github Actions job result
    # Required recipients' addresses:
    to: obiwan@example.com,yoda@example.com
    # Required sender full name (address can be skipped):
    from: Luke Skywalker # <user@example.com>
    # Optional whether this connection use TLS (default is true if server_port is 465)
    secure: true
    # Optional plain body:
    body: Build job of ${{github.repository}} completed successfully!
    # Optional HTML body read from file:
    html_body: file://README.html
    # Optional carbon copy recipients:
    cc: kyloren@example.com,leia@example.com
    # Optional blind carbon copy recipients:
    bcc: r2d2@example.com,hansolo@example.com
    # Optional recipient of the email response:
    reply_to: luke@example.com
    # Optional Message ID this message is replying to:
    in_reply_to: <random-luke@example.com>
    # Optional unsigned/invalid certificates allowance:
    ignore_cert: true
    # Optional converting Markdown to HTML (set content_type to text/html too):
    convert_markdown: true
    # Optional attachments:
    attachments: attachments.zip,git.diff,./dist/static/*.js
    # Optional priority: 'high', 'normal' (default) or 'low'
    priority: low
 ```
 

### Configuration

### Inputs

This Action defines the following formal inputs.

| Name | Req | Description
|-|-|-|
| **`account_name`**  | true | Account Name is mandatory.
| **`container`** | true | Container name is mandatory.
|**`sas`** | true | SAS Token is Mandatory for Azure Storage.
|**`keep_reports`** | false | Defaults to 0. If you want this action to delete reports which are more than certian limit, then mention that limit.
|**`report_url`** | true | Specify your website URL. You could use Github Secrets.
|**`allure_report`** | false | Defaults to allure-report.
|**`allure_history`** | false | Defaults to allure-history.
|**`allure_results`** | false | Defaults to allure-results. If your results are outputed to another folder, please specify.

    
### Outputs

This Action defines the following formal outputs.

None

### Azure Container Blob structure sample:- Organized by Github Run Number

Note:- Always the index.html points to Test Results History Page.

<img width="529" alt="image" src="https://user-images.githubusercontent.com/29324338/174486678-271f0cf2-e778-41cf-acc1-e4a119c01452.png">

### Azure Storage Blob Static Website Sample:- Full Report, Errors, Screenshots, Trace, Video is fully visible !

<img width="1440" alt="image" src="https://user-images.githubusercontent.com/29324338/174491177-d123103d-aedd-4ac0-8d58-cbdc570018a1.png">

