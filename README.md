# Local Geohistory Project: Application

[![DOI](https://zenodo.org/badge/622757413.svg)](https://zenodo.org/badge/latestdoi/622757413)

## Summary

The Local Geohistory Project aims to educate users and disseminate information concerning the geographic history and structure of political subdivisions and local government. This repository contains the application code used to power the [project website](https://www.localgeohistory.pro/en/). The application runs using the CodeIgniter 4 framework on a LAPP (Linux, Apache, PostgreSQL, PHP) stack, but can run on other operating systems when built using Docker.

This repository does not contain the data, which can be found in the [Open Data repository](https://github.com/localgeohistoryproject/open-data).

## Deployment

These instructions were created using Ubuntu; however, URLs to software instructions are provided to facilitate installations on other operating systems.

### Prerequisites

Several components must be installed to build the application. On Ubuntu, run the following code via Terminal:

```bash
sudo apt-get install git docker.io docker-compose-v2
```

More detailed installation instructions for Docker and Docker Compose are available at:

<https://docs.docker.com/compose/install/>

More detailed installation instructions for Git are available at:

<https://git-scm.com/downloads>

### Clone repository

Navigate to the folder where the application code will be downloaded, then run the following command using a program such as Command Prompt (Windows), Git BASH, or Terminal:

```bash
git clone https://github.com/localgeohistoryproject/application.git PHP
```

This will create a subfolder named **PHP**, which contains the application code.

### Create a .env file from the Sample.env

Within the newly-created **PHP** folder, the **env** folder contains a Sample.env file that can be used to create the necessary .env file for the application, which is where information like credentials is stored.

First, copy the Sample.env, and name the copy **.env** (with nothing before the period). Then, populate the values labeled ***, following the directions in the file.

### Modifications for other operating systems

The application uses symbolic links to propagate the .env file to 2 other locations without having to copy the .env file itself: the root of the **PHP** folder, and in the **src** folder. If you are deploying this application in another operating system, such as Windows, these symbolic links may not work, and the .env file in the **env** folder may have to be copied into these other locations. **If symbolic links are not used to propagate the .env files to other folders, the .gitignore file must be changed to prevent the inadvertent release of credentials by adding the following 2 files:**

```bash
.env
src/.env
```

The application also contains 2 Dockerfiles, one in **docker/php** and one in **docker/postgis**.

### Copy data files into the inpostgis folder

The **inpostgis** folder contains 2 SQL files containing the structural elements of the database. To replicate the data as presented on the [project website](https://www.localgeohistory.pro/en/), download the tab-separated values (TSV) files from the **data** folder in the [Open Data repository](https://github.com/localgeohistoryproject/open-data) and place them in the **inpostgis** folder.

### Build

The final step to deploying the application is to build it using Docker Compose. Run the following command using a program such as Command Prompt (Windows), Git BASH, or Terminal:

```bash
sudo docker compose up --detach
```

### Check installation

Navigate to <http://[::1]/en/> in your web browser to check if the application build was successful.

## Next steps

Once the application is built, tools such as pgAdmin can be used for data analysis with SQL. Because the PostgreSQL instance is installed locally, the hostname for connection is **localhost**, and the remaining credentials are stored in the .env file. More information concerning the installation of pgAdmin is available at:

<https://www.pgadmin.org/download/>

## Notes

This project is tested with BrowserStack.