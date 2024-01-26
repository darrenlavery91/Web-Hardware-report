# Web-Hardware-report

This Ansible playbook is designed to gather system information from remote hosts and create an HTML report. The report includes details such as user information, hostname, IP address, disk usage, uptime, memory usage, kernel information, and more.

## Prerequisites

Before running this playbook, ensure the following prerequisites are met on the control machine and target hosts:

1. **Ansible Installed:**
   - Ensure Ansible is installed on your control machine. If not, you can install it using:

     ```bash
     sudo apt-get install ansible   # For Debian/Ubuntu
     sudo yum install ansible       # For RHEL/CentOS
     ```

2. **HTTP Server (httpd) Installed:**
   - Make sure the Apache HTTP server (`httpd`) is installed on the target host where the HTML reports will be hosted. Install it using:

     ```bash
     sudo systemctl status httpd
     ```

3. **Web Directory Created:**
   - Create the web directory `/var/www/html` on your ansible host. You can use the following Ansible command:

     ```bash
     sudo mkdir -p /var/www/html
     ```

4. **HTTP Server Running:**
   - Ensure the HTTP server (`httpd`) is running on the target host. You can start or restart the service using:

     ```bash
     sudo ansible -m service -a "name=httpd state=started" -i inventory_file localhost
     ```

## Usage

1. Ensure Ansible is installed on your control machine.
2. Update the inventory file with the target hosts.
3. Execute the playbook:

```
ansible-playbook -i inventory_file Web-Hardware-report.yml
```

## Playbook: Web-Hardware-report.yml

```yaml
- name: Gather System Information and Create HTML Report
  hosts: all
  become: true
  tasks:
    - name: Gather User Information
      shell: getent passwd
      register: users_info

    - name: Gather Hostname and DNS Name
      shell: hostname
      register: system_info

    - name: Gather IP Address
      shell: ip a | grep "X.X."
      register: network_info

    - name: Gather Disk Usage
      shell: df -h
      register: disk_info

    - name: Gather Uptime
      shell: uptime
      register: uptime_info

    - name: Gather Memory Usage
      shell: free -m
      register: memory_info

    - name: Gather Kernel Number
      debug:
        var: ansible_facts.bios_version
      register: os_info
      
    - name: Kernal infos
      shell: uname -a
      register: kernel_info
    
    - name: Create HTML Report
      template:
        src: /darren_ansible/template/main.html.j2
        dest: /var/www/html/login.html
      delegate_to: localhost

    - name: Create HTML Report
      template:
        src: /darren_ansible/template/system_info_template.html.j2
        dest: "/var/www/html/system_info_{{ inventory_hostname }}.html"
      loop: "{{ ansible_play_batch }}"
      delegate_to: localhost

    - name: Create index Report
      template:
        src: /darren_ansible/template/index.html.j2
        dest: "/var/www/html/index.html"
      delegate_to: localhost 
    
```

## Templates

### main.html.j2

```html
<!-- Main HTML template for login page -->
<!-- ... (see contents of main.html.j2) -->
```

### system_info_template.html.j2

```html
<!-- Template for individual system information reports -->
<!-- ... (see contents of system_info_template.html.j2) -->
```

### index.html.j2

```html
<!-- Template for the index page with links to individual system reports -->
<!-- ... (see contents of index.html.j2) -->
```

## Style and Images

The HTML templates include styles for a visually appealing report. Images are referenced from the '/img/' directory.

## Author

Darren Lavery

Feel free to customize the playbook, templates, and styles to suit your specific requirements.
```


