## Config module by Ashley Broughton
from types import Config
import os
import tables
import json
import strutils
import logging
from os import getEnv

const config_file_name = "config.json"
let config_dir = joinPath(getConfigDir(), "nimneural")
let config_file_path = joinPath(config_dir, config_file_name)


proc defaultConfig(): Config =
  result.dBias = -1
  result.dActivationResponse = 1
  result.dMaxPerturbation = 0.3
  result.NumInputs = 4
  result.NumHidden = 1
  result.NeuronsPerHiddenLayer = 6
  result.NumOutputs = 2
  result.MutationRate = 0.1
  result.CrossoverRate = 0.7
  result.NumEliteCopies = 1
  result.NumElite = 4

proc configToJsonString(config: Config): string =
  var t = initOrderedTable[string, JsonNode]()
  t.add("dBias", newJInt(config.dBias))
  t.add("dActivationResponse", newJInt(config.dActivationResponse))
  t.add("NumInputs", newJInt(config.NumInputs))
  t.add("NumHidden", newJInt(config.NumHidden))
  t.add("NeuronsPerHiddenLayer", newJInt(config.NeuronsPerHiddenLayer))
  t.add("NumOutputs", newJInt(config.NumOutputs))
  t.add("NumEliteCopies", newJInt(config.NumOutputs))
  t.add("NumElite", newJInt(config.NumOutputs))

  t.add("dMaxPerturbation", newJFloat(config.dMaxPerturbation))
  t.add("MutationRate", newJFloat(config.MutationRate))
  t.add("CrossoverRate", newJFloat(config.CrossoverRate))

  var jobj = newJObject()
  jobj.fields = t

  result = pretty(jobj) & "\n"

proc readConfig(): Config =
  var json_node: JsonNode
  json_node = parseFile(config_file_path)
  result.dBias = json_node["dBias"].getInt
  result.dActivationResponse = json_node["dActivationResponse"].getInt
  result.NumInputs = json_node["NumInputs"].getInt 
  result.NumHidden = json_node["NumHidden"].getInt
  result.NeuronsPerHiddenLayer = json_node["NeuronsPerHiddenLayer"].getInt
  result.NumOutputs = json_node["NumOutputs"].getInt
  result.NumEliteCopies = json_node["NumEliteCopies"].getInt
  result.NumElite = json_node["NumElite"].getInt

  result.dMaxPerturbation = json_node["dMaxPerturbation"].getFloat
  result.MutationRate = json_node["MutationRate"].getFloat
  result.CrossoverRate = json_node["CrossoverRate"].getFloat

proc loadConfig*(): Config =
  let first_run = not existsOrCreatedir(config_dir)
  let config_exists = existsFile(config_file_path)
  
  if first_run or not config_exists:
    writeFile(config_file_path, configToJsonString(defaultConfig()))

  try:
    result = readConfig()
  except:
    echo("Failed to read config file from: " & config_file_path)
    raise

proc nimneuralConfigFilePath*(): string = 
  return config_file_path
