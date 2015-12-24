# Install

## Ubantu

google-chrome-stable is availeble on 3rd Party Repository: Google Chrome (For Stable).

Follow the instruction for installation:

1. Add Key:

    ```bash
    user ~$ wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    ```

2. Set repository:

    ```bash
    user ~$ sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    ```

3. Install package:

    ```bash
    user ~$ sudo apt-get update
    user ~$ sudo apt-get install google-chrome-stable
    ```
