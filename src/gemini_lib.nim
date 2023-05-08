# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.
import std/net
import std/uri
import strutils

const CRLF = "\r\n"

proc transaction*(uri: string): string =

#validate the address
#if !validateAddress(address):
#return "Gemini-library error: invalid address"

#Parse the address
        let host = parseUri(uri)
        const port = Port(1965)
        let hostname = host.hostname

#connect to server
        let socket = newSocket()
        let ctx = newContext(verifyMode = CVerifyNone)
        wrapSocket(ctx, socket)
        socket.connect(hostname, port)

#send request
        socket.send(uri & CRLF)

#receive request
        var line = socket.recvLine()
        var result = line & CRLF
        while line != "":
           line = socket.recvLine()
           result = result & line & CRLF

        return result

type 
    TransactionResult* = object
        statusCode*, simpleCode*: int
        responseBody*, responseHeader*, fullResponse*, mimeType*: string
        responseLines*: seq[string]

proc createTransactionResult*(obj: var TransactionResult, response: string) =
    obj.fullResponse = response
    obj.responseLines = obj.fullResponse.split(CRLF)
    
    # Pull response header from lines
    obj.responseHeader = obj.responseLines[0]
    obj.responseLines.delete(0)
    # Status code from header
    obj.statusCode = obj.responseHeader.split(" ")[0].parseInt()
    obj.simpleCode = int(obj.statusCode / 10)
    # Mime type from header
    obj.mimeType = obj.responseHeader.split(obj.statusCode.intToStr() & " ")[^1]

    # Make responseBody from lines
    for line in obj.responseLines:
        obj.responseBody = obj.responseBody & "\n" & line
    obj.responseBody.removePrefix()

    
    # Handle errors

    #Status code length
    if obj.statusCode > 62 or obj.statusCode< 10:
        obj.mimeType = "error"
        obj.responseBody = "Error, status code length is invalid"
    #<META> size
    if obj.mimeType.len() > 127: # RFC 4288 max is 127 characters, not exactly gemini spec but good enough
        obj.mimeType = "error"
        obj.responseBody = "Error, mime type length too long, META tag"
    

