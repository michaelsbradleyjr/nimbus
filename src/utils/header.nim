import ../constants, ttmath, strformat

type
  Header* = ref object
    timestamp*: int
    difficulty*: UInt256
    blockNumber*: UInt256
    hash*: string
    coinbase*: string
    gasLimit*: UInt256
    stateRoot*: string

  # TODO

proc `$`*(header: Header): string =
  if header.isNil:
    result = "nil"
  else:
    result = &"Header(timestamp: {header.timestamp} difficulty: {header.difficulty} blockNumber: {header.blockNumber} gasLimit: {header.gasLimit})"

proc generateHeaderFromParentHeader*(
    computeDifficultyFn: proc(parentHeader: Header, timestamp: int): int,
    parentHeader: Header,
    coinbase: string,
    timestamp: int = -1,
    extraData: string = string""): Header =
  Header()
  # Generate BlockHeader from state_root and parent_header
  # if timestamp is None:
  #       timestamp = max(int(time.time()), parent_header.timestamp + 1)
  #   elif timestamp <= parent_header.timestamp:
  #       raise ValueError(
  #           "header.timestamp ({}) should be higher than"
  #           "parent_header.timestamp ({})".format(
  #               timestamp,
  #               parent_header.timestamp,
  #           )
  #       )
  #   header = BlockHeader(
  #       difficulty=compute_difficulty_fn(parent_header, timestamp),
  #       block_number=(parent_header.block_number + 1),
  #       gas_limit=compute_gas_limit(
  #           parent_header,
  #           gas_limit_floor=GENESIS_GAS_LIMIT,
  #       ),
  #       timestamp=timestamp,
  #       parent_hash=parent_header.hash,
  #       state_root=parent_header.state_root,
  #       coinbase=coinbase,
  #       extra_data=extra_data,
  #   )

  #   return header

proc computeGasLimit*(header: Header, gasLimitFloor: UInt256): UInt256 =
  # TODO
  gasLimitFloor

proc gasUsed*(header: Header): UInt256 =
  # TODO
  0.u256

proc gasLimit*(header: Header): UInt256 =
  # TODO
  0.u256
