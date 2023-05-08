# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import gemini_lib
import std/strutils
const CRLF = "\r\n"
let result: string = transaction("gemini://gemini.circumlunar.space")
var obj = TransactionResult() 
obj.createTransactionResult(result)

test "statusCode":
    echo obj.statusCode
    assert obj.statusCode == 31
test "simplifiedCode":
    echo obj.simpleCode
    assert obj.simpleCode == 3
test "mimeType":
    echo obj.mimeType
    assert obj.mimeType == "gemini://gemini.circumlunar.space/"
test "responseLines":
    echo obj.responseLines
test "responseBody":
    echo obj.responseBody
test "responseHeader":
    echo obj.responseHeader
