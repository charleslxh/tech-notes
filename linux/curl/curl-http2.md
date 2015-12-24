# Use Curl Send HTTP2

Installing HTTP2 support with the curl command

## Command Rundown

1. Just to get us started (really only need git), If you have them, ignore this step:

    ```bash
    user $ sudo apt-get install -y tmux curl vim wget htop git
    ```

2. Check the curl can run:

    ```bash
    user $ curl -I https://nghttp2.org/

    > HTTP/1.1 200 OK
    > Date: Fri, 04 Dec 2015 00:00:06 GMT
    > Content-Type: text/html
    > Content-Length: 6680
    > Last-Modified: Thu, 26 Nov 2015 15:28:33 GMT
    > Etag: "56572521-1a18"
    > Accept-Ranges: bytes
    > X-Backend-Header-Rtt: 0.000642
    > Server: nghttpx nghttp2/1.5.1-DEV
    > Via: 1.1 nghttpx
    > strict-transport-security: max-age=31536000
    ```

    From the result: We can see it returns HTTP1.1 response.

3. Try to send `HTTP2`:

    ```bash
    user $ curl --http2 -I https://nghttp2.org/

    (1)unsupported protocol
    ```

    If get the error message, go on and upgrade CURL to lastest which support HTTP2. Otherwise, you need not do
    run following command.

4. Install ngHttp2:

    CURL supports http2 must depend on third party module [ngHttp2](https://nghttp2.org/), it a `C` library.

    Install dependences

    ```bash
    # Get build requirements
    # Some of these are used for the Python bindings
    # this package also installs
    user $ sudo apt-get install g++ make binutils autoconf automake autotools-dev libtool pkg-config \
      zlib1g-dev libcunit1-dev libssl-dev libxml2-dev libev-dev libevent-dev libjansson-dev \
      libjemalloc-dev cython python3-dev python-setuptools
    ```

    If you install them failed with `dependencies error`, you can try this first, then run the above commands

    ```
    user $ sudo apt-get -f install
    ```

    Clone the nghttp2 source code from git

    ```bash
    # Build nghttp2 from source
    user $ git clone https://github.com/tatsuhiro-t/nghttp2.git

    # If you have github account and have configured the SSH key, you can try this
    user $ git clone git@github.com:tatsuhiro-t/nghttp2.git
    ```

    Build nghttp2

    ```bash
    user $ cd nghttp2
    user $ autoreconf -i
    user $ automake
    user $ autoconf
    user $ ./configure
    user $ make
    user $ sudo make install
    ```

5. Upgrade or install lastest CURL:

    ```bash
    user $ cd ~
    user $ sudo apt-get build-dep curl
    user $ wget http://curl.haxx.se/download/curl-7.46.0.tar.bz2
    user $ tar -xvjf curl-7.46.0.tar.bz2
    user $ cd curl-7.46.0
    user ~/curl-7.46.0$ ./configure --with-nghttp2=/usr/local --with-ssl
    user ~/curl-7.46.0$ make & sudo make install
    user ~/curl-7.46.0$ sudo ldconfig
    ```

6. Retry the CURL can send HTTP2 request:

    ```bash
    user $ curl --http2 -I https://nghttp2.org/

    > HTTP/2.0 200
    > server:nginx/1.9.7
    > date:Fri, 04 Dec 2015 02:20:54 GMT
    > content-type:text/html
    > content-length:12
    > last-modified:Fri, 04 Dec 2015 02:11:11 GMT
    > etag:"5660f63f-c"
    > accept-ranges:bytes
    ```

    If you get errors, May be the CURL path is wrong, you can try setting this constant to tell curl where to find shared libraries.

    ```bash
    user $ LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/curl --http2 -I nghttp2.org

    > HTTP/2.0 200
    > server:nginx/1.9.7
    > date:Fri, 04 Dec 2015 02:20:54 GMT
    > content-type:text/html
    > content-length:12
    > last-modified:Fri, 04 Dec 2015 02:11:11 GMT
    > etag:"5660f63f-c"
    > accept-ranges:bytes
    ```

