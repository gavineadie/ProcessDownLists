# ProcessDownLists

You'll be reading this only if you know quite a lot about the [Virtual
AGC](https://www.ibiblio.org/apollo/) project so I'm not not going to cover that
very well documented material.

This so-called `ProcessDownLists` command line application reads particular
Apollo Guidance Computer source code files and generates tab separated value
(tsv) files that describe the data stream (the 'downlist', 100 words sent every
two seconds) which is transmitted, in telemetry, from an Apollo capsule to
ground stations for ultimate display on mission controllers' consoles.

In the Virtual AGC project, those tsv files are used by the `yaTelemetry`
application to display that data as sent from an emulated AGC.

### The application

`ProcessDownLists` is written in Swift.  It is what I call
a 'GLP' (Grungy Little Program) in that it is a `main` program that calls
a sequence of functions that
progressively translated the AGC source to the tsv files. As I learned how the AGC
source was used, the program grew to cope.

Each Apollo mission's AGC code contains a file named `DOWNLINK_LISTS.agc`. These
files are the the part which describe the several 'downlists' for each mission,
and which `ProcessDownLists` reads.  Given the constraints of the day, the
programmers employed clever tricks to use as little AGC memory as possible; in
particular, when the same groups of words were to be transmitted in different
flight modes (Coasting, Rendezvous, Descent, etc), those groups were separated
into common sections and included in that mode's 'downlist', where necessary.

`ProcessDownLists` has to deal with two challenges.  One is the intricate
process of gathering the above mentioned 'common blocks' and inserting them at
the right places in each 'downlist'.

The other challenge is that the AGC source code in the `DOWNLINK_LISTS.agc`
files cannot be sufficiently descriptive to provide all that's needed.  For
example, the instruction `3DNADR APOGEE` means add the __three__ 'words',
starting at the address labeled `APOGEE`, to the 'downlist'.  However, without
recourse to other parts of the source code, there's no information about what
the following 'words' might be, and this is compounded by some 'words' actually
being two 'half-words'.

I suspect this was an issue for the original authors too because the comment
fields of each line contain the necessary information.  The challenge continues
because these comments are just that, comments, so not constrained to strict
format.  Some conventions are, mostly, followed but the interpretation of the
comment fields is complicated and involved some trial and error -- and some
errors may remain.

### Platform and Use

As mentioned, `ProcessDownLists` is written in Swift.  It was authored on a Mac
but, since it's a command line executable, it has no need for any Mac-specific
usages and can be built and run on Linux too (and, maybe, Windows too).

In it's current state (remember, GLP), `ProcessDownLists` expects to find the
Virtual AGC project at `~/Developer/virtualagc/` and will write all it's output
to `~/Desktop/Downlist/`.  __NOTE:__ options to specify these directories will
be added soon.

```
   cd ~/Developer/ProcessDownLists
   swift build
   ./.build/debug/ProcessDownLists
```

### Swift

Though Swift was a creation of Apple, is open-source and available on 
most platforms.  It is an integral part of Apple's IDE (Xcode) and a
supported plug-in for Visual Studio Code.  It is also a stand-alone 
compiler usable without the above IDEs.

As I write this, a convenient cross-platform tool for the installation
of Swift has come available.  It is called `Swiftly` and lives at 
https://www.swift.org/swiftly/

I've used `Swiftly` to install Swift on Ubuntu and used that installation to build and run 
`ProcessDownLists`.  For what it's worth, here's abbreviated 
transcript of that (the multi-line command that comes first is copied
and pasted from that above web documentation):

```
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-57-generic x86_64)

→ :~$ curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
tar zxf swiftly-$(uname -m).tar.gz && \
./swiftly init --quiet-shell-followup && \
. ~/.local/share/swiftly/env.sh && \
hash -r
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 27.2M  100 27.2M    0     0  16.1M      0  0:00:01  0:00:01 --:--:-- 16.1M
Swiftly will be installed into the following locations:

/home/guest/.local/share/swiftly - Data and configuration files directory including toolchains
/home/guest/.local/share/swiftly/bin - Executables installation directory

These locations can be changed with SWIFTLY_HOME_DIR and SWIFTLY_BIN_DIR environment variables and run this again.

Once swiftly is installed it will install the latest available swift toolchain. 
In the process of installing the new toolchain swiftly will add swift.org GnuPG keys 
into your keychain to verify the integrity of the downloads.

Proceed? (Y/n): 
y
Installing swiftly in /home/guest/.local/share/swiftly/bin/swiftly...
Creating shell environment file for the user...
Updating profile...
Fetching the latest stable Swift release...
Installing Swift 6.1.0
                                Downloading Swift 6.1.0
100% [==================================================================================]
Downloaded 839.6 MiB of 839.6 MiB

Verifying toolchain signature...
Extracting toolchain...
The global default toolchain has been set to `Swift 6.1.0`
Swift 6.1.0 installed successfully!

[ NOTE: You may not need to do this -- I did ]
| There are some dependencies that should be installed before using this toolchain.
| You can run the following script as the system administrator (e.g. root) to prepare
| your system:
| 
|     apt-get -y install libpython3-dev
| 
| → :~$ sudo apt-get -y install libpython3-dev
| [sudo] password for guest: 
| Reading package lists... Done
| Building dependency tree... Done
| Reading state information... Done
| The following additional packages will be installed:
|   libpython3.12-dev
| The following NEW packages will be installed:
|   libpython3-dev libpython3.12-dev
| 0 upgraded, 2 newly installed, 0 to remove and 1 not upgraded.
| Need to get 5,685 kB of archives.
| After this operation, 29.7 MB of additional disk space will be used.
|  . . . 
 
→ :~$ swift --version
Swift version 6.1 (swift-6.1-RELEASE)
Target: x86_64-unknown-linux-gnu

→ :~$ cd Developer/ProcessDownLists/
→ :~/Developer/ProcessDownLists$ swift build
[1/1] Planning build
Building for debugging...
 . . .
[25/25] Linking ProcessDownLists
Build complete! (11.84s)

→ :~/Developer/ProcessDownLists$ swift run
Building for debugging...
[1/1] Write swift-version-27DA9706154FFCF8.txt
Build of product 'ProcessDownLists' complete! (0.20s)
file:///home/guest/Developer/virtualagc/LUM69R2/DOWNLINK_LISTS.agc
file:///home/guest/Developer/virtualagc/Luminary131/DOWNLINK_LISTS.agc
 . . . 
file:///home/guest/Developer/virtualagc/Comanche044/DOWNLINK_LISTS.agc
file:///home/guest/Developer/virtualagc/LUM99R2/DOWNLINK_LISTS.agc

tidyFile: Processed LUM69R2.
mashFile: Processed LUM69R2.
listFile: Processed LUM69R2.
joinFile: Processed LUM69R2.
dataFile: Processed LUM69R2.
xtraFile: Processed LUM69R2.
File successfully written to: /home/guest/Desktop/Downlist/tsv/ddd-77776-LUM69R2.tsv
File successfully written to: /home/guest/Desktop/Downlist/tsv/ddd-77777-LUM69R2.tsv
File successfully written to: /home/guest/Desktop/Downlist/tsv/ddd-77773-LUM69R2.tsv
File successfully written to: /home/guest/Desktop/Downlist/tsv/ddd-77772-LUM69R2.tsv
File successfully written to: /home/guest/Desktop/Downlist/tsv/ddd-77774-LUM69R2.tsv
File successfully written to: /home/guest/Desktop/Downlist/tsv/ddd-77775-LUM69R2.tsv
sortFile: Processed LUM69R2.
 . . . 
 
→ :~/Developer/ProcessDownLists$ 
```

.. all done and desired tsv files in `/home/guest/Desktop/Downlist/tsv/`

### Program Details

`ProcessDownLists` is a `main` program that calls a sequence of functions that
progressively translate the AGC source to the tsv files.

“tidyFile” .. cleans up the AGC code

* scan the whole DOWNLINK_LISTS.agc file for bulk replacements.  To avoid
   complications related to adding or removing lines, the replacements
   don't add or remove lines.                            

* delete blank lines, blank comment lines and page number lines ..                       

* where a comment overflows to the next line (two cases), unwrap them ..                 

“mashFile” .. gathers the common sections and emits a “list” file showing them. This file is not used again, it’s for visual examination and was vital for checking multi-use common sections ..

* process the lines of the file to isolate downlists, snapshots and commmon
   data.  These are collected in memory and used by the "Join" process ..                                               

“joinFile” .. start to build the final form, put the common sections in the right places and insert downlist indices and GSOP numbers for checks ..

* add three line header, eg:                                                      
```
    ## ============================================================================
    ## Apollo 13 LM [LM131R1] -- Coast and Align (LM-77777)                        
    ## ============================================================================
```
* add "title" line ..                                                             
```
    Coast and Align                                                                
```
* add ID,SYNC line which is not in the AGC code                                   
```
        1DNADR 77777                        #   (  000  )   1 # ID,SYNC  
```
* add index range and GSOP word number                        

* insert common sections (annotated with comments)          

“dataFile” .. put the common sections in the right places and add downlist and GSOP numbers .. also edits more inconsistent usages and typos ..

* remove prefixes "# " and "#*" (the common section annotations) ..            

* edits a whole pile of lines with typos and inconsistent usage ..

“xtraFile” .. adds the scale, format, formatter and units and does a sanity check .. emits a per-mission TSV file.

* adds "# offset N is unused"

“sortFile” .. reads a per-mission TSV file and outputs per-ID TSV files to /tsv/ directory.

### Diagnostics

Each function can emit an intermediate file for diagnostic examination.  They will be emitted if the
command line option `-d` is used. 
```
./.build/debug/ProcessDownLists -d
```
