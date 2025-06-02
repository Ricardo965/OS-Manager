# OS-Manager

Operative System Manager made on PowerShell and Bash for Linux and Windows compatibility, for Data Centers.

## 🧭 Introduction

This project aims to develop two command-line tools: one in **PowerShell** (for Windows environments) and another in **Bash** (for Linux environments). Both are designed to simplify daily administrative tasks in a **data center** managing mixed operating systems.

These tools automate common tasks related to **process**, **user**, **backup**, and **system shutdown** management, helping to reduce manual errors and improve administrative efficiency.

---

## 🎯 Script Objectives

- Automate repetitive system administrator tasks.
- Facilitate basic system administration.
- Consolidate common functionalities into a single interactive menu.

---

## ⚙️ Features

The tool provides a **fully functional menu** with the following options:

### 🔍 Processes

- List all system processes.
- Show the **top 5 processes consuming the most CPU** (in descending order).
- Show the **top 5 processes consuming the most memory** (in descending order).
- Terminate a process by entering its PID.

### 👤 Users

- List all system users.
- Show a list of users sorted by **password age**.
- Change the password of a specified user.

### 🗃️ Backup

- Perform a **backup of the users directory** (`/home` on Linux or its Windows equivalent).
- The backup file will include the **execution date** in its name.
- The backup script runs **automatically every day at 3:00 a.m** using a cron job.
  To configure a cron job on **Linux**, we use `sudo crontab -e` to open cron config panel and we add the following line:

  ```bash
  0 3 * * * /usr/local/bin/backup_usuarios_auto.sh

  ```

  On the folder linux, cronJob.sh is the script designed to run automatically when the cron is triggered for creating a `/home` backup.

### ⏻ Shutdown

- Allows controlled system shutdown from the menu.

---

## 📅 Backup Automation

- On Linux, `cron` is used to schedule automatic execution of the backup script at **03:00 a.m.** daily.
- On Windows, the **Task Scheduler** can be used to achieve the same behavior.

---

## 👨‍💻 Contributors

- **Ricardo Urbina**
- **Kevin Nieto**
- **Andrés Bueno**

---

## 📁 Repository Structure

```
.
├── linux
│   └── manager.sh
├── README.md
└── windows
    └── manager.ps1
```

---

## 📝 Final Notes

- It is recommended to run the scripts with administrator or root privileges.
- Make sure you have the necessary permissions to list processes and change passwords.

---
