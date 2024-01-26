# Web-Hardware-report

This Ansible playbook is designed to gather system information from remote hosts and create an HTML report. The report includes details such as user information, hostname, IP address, disk usage, uptime, memory usage, kernel information, and more.

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
      shell: ip a | grep "10.10."
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


