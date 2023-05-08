# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import nimini_lib
import std/strutils
import std/uri

###let result: string = transaction("gemini://gemini.circumlunar.space/")
#var obj = TransactionResult() 
#obj.createTransactionResult(result)

proc connect(url: string) =
    var fetched = TransactionResult()
    fetched.createTransactionResult(transaction(url))

    echo "\n"
    echo fetched.responseHeader 
    if fetched.simpleCode == 1:
        echo "INPUT: "
        connect(url & "?" & encodeUrl(readLine(stdin)))
        return
    
    var links = newSeq[string]()
    for line in fetched.responseLines:
        if "=>" in line:
            var link = line
            link.removePrefix("=>")
            link.removePrefix(" ")
            link = link.split()[0]
            if not (link.contains("://")):
                var tempS = "gemini://" & parseUri(url).hostname 
                if not (link[0] == '/'):
                    tempS = tempS & '/'
                link = tempS & link
            echo links.len,  line
            links.add(link)
        else:
            if line.len > 0:
                echo line
    echo "\n"
    echo "Enter a number to goto one of the listed links, otherwise enter -1:"
    for i in 0..links.len-1:
        echo i, ". " & links[i] 
    let temp = readLine(stdin).parseInt()

    if temp < 0 or temp >= links.len:
        return
    echo links[temp]
    connect(links[temp])

while true:
    echo "Please enter a valid gemini url:"
    let url = readLine(stdin)
    connect(url)


         
