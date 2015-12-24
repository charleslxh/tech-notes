# Upgrade

## Ubantu

1. First download and install the key from Google Linux Repository. Or run the following commands in the terminal, type the password for the user when prompted.

    -   Add key:
    
        ```bash
        user ~$ wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        ```
    
    -   Set repository:
    
        ```bash
        user ~$ sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
        ```

2. Install the chrome

    ```bash
    user ~$ sudo apt-get update
    user ~$ sudo apt-get install google-chrome-beta
    ```

3. Run update only
    
    ```bash
    user ~$ sudo apt-get --only-upgrade install google-chrome-stable
    ```

4. This will install the current stable version of it. Now you must kill all instances (May close old chrome)

    ```bash
    user ~$ Kill -15 google-chrome
    user ~$ kill -15 chrome
    ```

5. Restart chrome
    
    ```bash
    user ~$ google-chrome
    ```
