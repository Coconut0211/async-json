import os
import json, sequtils
import strutils
import parsecsv  # скорее всего не пригодится
import asyncdispatch
import asyncfile
import random
import times

const MAX_DELAY = 5
const MILISEC = 1000
randomize()


proc toJson(data: seq[tuple[k, v: string]]): JsonNode =
  ## Функция реализует преобразование данных в JSON-ноду
  ## Лучше всего для корректной конвертации в JSON,
  ## взять объекты из проекта базы данных и работать с ними
  ## Если не получается, то версия из thread-json подойдет.


proc readCSV(filename: string): Future[seq[JsonNode]] {.async.} =
  ## Функция реализует чтение данных из принятого файла
  ## и упаковывает их в последовательность Json-нод.
  ## Многопоточную версию необходимо подправить под асинхронность,
  ## так как в противном случае тест не будет пройден.
  await sleepAsync(rand(MAX_DELAY * MILISEC))  # имитация больших данных
  # реализуйте обработку CSV в асинхронном режиме. В лекции такое было.


proc loadCSV(filename: string) {.async.} =
  ## На данный момент, корутина сохраняет результат чтения данных из CSV в JSON
  let file = openAsync("data" / filename.splitFile.name & ".json", fmWrite)
  # обратите внимание, readCSV - корутина
  await file.write((%*(await readCSV(filename))).pretty(4))
  file.close()

proc main() {.async.} =
  ## Корутина верхнего уровня
  # Возьмите все CSV файлы из папки "data"
  # Сформируйте корутину work, в которую внесете все промисы для каждого файла
  # Запустите корутину work в работу


when isMainModule:
  assert walkFiles("data" / "*.csv").toSeq.len != 0
  let start = now()
  waitFor main()
  assert now() - start < initDuration(seconds=MAX_DELAY)
