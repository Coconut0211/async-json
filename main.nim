import os
import json, sequtils
import strutils
import asyncdispatch
import asyncfile
import random
import unittest
import times

const DELAY = 5
const MILISEC = 1000
randomize()


proc toJson(data: seq[tuple[k, v: string]]): JsonNode =
  result = newJObject()
  for item in data:
    result[item.k] = %* item.v.replace("\"","")


proc readCSV(filename: string): Future[seq[JsonNode]] {.async.} =
  await sleepAsync(rand(DELAY * MILISEC))  # имитация больших данных
  var csv: AsyncFile
  csv = openAsync(filename)
  var csvData = (await csv.readAll).splitlines.mapIt(it.split(","))
  csv.close()
  for row in csvData[1..^2]:
    result.add(zip(csvData[0],row).toJson())



proc loadCSV(filename: string) {.async.} =
  let file = openAsync("data" / filename.splitFile.name & ".json", fmWrite)
  await file.write((%*(await readCSV(filename))).pretty(4))
  file.close()

proc main() {.async.} =
  let files = walkFiles("data" / "*.csv").toSeq
  let work = files.mapIt(loadCSV(it))
  await all(work)
 

when isMainModule:
  test "Looking data dir":
    check walkFiles("data" / "*.txt").toSeq.len == 0
    check walkFiles("data" / "*.csv").toSeq.len == 9
  let start = now()
  waitFor main()
  test "Check delay":
    check now() - start < initDuration(seconds=DELAY)
  test "JSON in data dir":
    check walkFiles("data" / "*.json").toSeq.len == 9
