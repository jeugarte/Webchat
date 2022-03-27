# Installation Instructions

## Introduction

After unzipping our project, drill down (using the `cd` command) so you are in the "WebChat" directory. The "WebChat" directory should be in the same parent directory as this installation file.


## Installing Ocaml 4.13.1

Our project requires you to have Ocaml version 4.13.1. You likely do not have this installed (none of us did), but to check you can run in your terminal:

`ocaml -version`

To install Ocaml version 4.13.1, run the following commands in your terminal (even if you are on version 4.13.1, we suggest you run this anyway):

`opam switch create 4.13.1`

`eval $(opam env)`

The first command will likely take a while to complete since it is reinstalling a new version of Ocaml. After these both have succesfully run, check your Ocaml version again to make sure it has updated correctly:

`ocaml -version`


## Installing Ocaml Libraries

Since you likely just updated your version of Ocaml, you should reinstall all the relevant libraries that are necessary for our app:

`opam install dune`

`opam install ounit2`

`opam install opium`

Some of these installations may ask for your permission or ask a y/n question. Just enter "y" and continue with the installation.

With Ocaml 4.13.1 and these libraries installed, you should be ready to run our app!



# Run Instructions

## Running the App

To run the app, first be sure that you are still in the "WebChat" directory, and then run the following in your terminal:

`dune build`

`make run`

If you get a "Fatal error" after running this last command, it may be because the 3000 port of your localhost is currently in use. If this is the case, you need to find the PID of the process that is running on port 3000 and kill it. [This forum](https://superuser.com/questions/1411293/how-to-kill-a-localhost8080) gives a good outline on how to do this depending on your OS (just replace all instances of "8080" with "3000").

## Accessing the App

The server should now be running. Requests can be made to http://localhost:3000 and the frontend of the app can be found by visiting http://localhost:3000/index.html in a web browser. The app can be also be accessed (and requests can be made) by visiting http://[_YOUR NETWORK IP_]:3000/index.html on any device connected to the same network your computer is connected to. Finding out your network IP varies with OS, but a simple google search should tell you how to find it.

## Cleaning the App

Even if you terminate the command by typing `^c` (ctrl-c), the app will still be running because the server is technically never closed. Now, if you try to run the `make run` command again, you will get a "Fatal error" (even though the app will still be running). To circumvent this and clear the 3000 port of your localhost, run `make clean` in your terminal. If this does not work (one person in our group using Ubuntu was having this problem), instead just manually run the following command in your terminal:

`pkill -f _build/default/ocaml_webapp/bin/main.exe`

If this command gives an error, it likely means that port 3000 of your localhost is actually not currently being used and any problems with running `make run` may be due to other errors.