import
  macros, strformat, tables,
  logging, constants, ttmath, errors, transaction, db/db_chain, utils/state, utils/header

type
  BaseVMState* = ref object of RootObj
    prevHeaders*: seq[Header]
    # receipts*:
    chaindb*: BaseChainDB
    accessLogs*: AccessLogs
    blockHeader*: Header
    name*: string

  AccessLogs* = ref object
    reads*: Table[string, string]
    writes*: Table[string, string]

proc newAccessLogs*: AccessLogs =
  AccessLogs(reads: initTable[string, string](), writes: initTable[string, string]())

proc update*[K, V](t: var Table[K, V], elements: Table[K, V]) =
  for k, v in elements:
    t[k] = v

proc `$`*(vmState: BaseVMState): string =
  if vmState.isNil:
    result = "nil"
  else:
    result = &"VMState {vmState.name}:\n  header: {vmState.blockHeader}\n  chaindb:  {vmState.chaindb}"

proc newBaseVMState*: BaseVMState =
  new(result)
  result.prevHeaders = @[]
  result.name = "BaseVM"
  result.accessLogs = newAccessLogs()
  result.blockHeader = Header(hash: "TODO", coinbase: "TODO", stateRoot: "TODO")

method logger*(vmState: BaseVMState): Logger =
  logging.getLogger(&"evm.vmState.{vmState.name}")

method blockhash*(vmState: BaseVMState): string =
  vmState.blockHeader.hash

method coinbase*(vmState: BaseVMState): string =
  vmState.blockHeader.coinbase

method timestamp*(vmState: BaseVMState): int =
  vmState.blockHeader.timestamp

method blockNumber*(vmState: BaseVMState): UInt256 =
  vmState.blockHeader.blockNumber

method difficulty*(vmState: BaseVMState): UInt256 =
  vmState.blockHeader.difficulty

method gasLimit*(vmState: BaseVMState): UInt256 =
  vmState.blockHeader.gasLimit

method getAncestorHash*(vmState: BaseVMState, blockNumber: UInt256): string =
  var ancestorDepth = vmState.blockHeader.blockNumber - blockNumber - 1.u256
  if ancestorDepth >= constants.MAX_PREV_HEADER_DEPTH or
     ancestorDepth < 0 or
     ancestorDepth >= vmState.prevHeaders.len.u256:
    return ""
  var header = vmState.prevHeaders[ancestorDepth.getUInt.int]
  result = header.hash

macro db*(vmState: untyped, readOnly: untyped, handler: untyped): untyped =
  # vm.state.db:
  #   setupStateDB(fixture{"pre"}, stateDb)
  #   code = db.getCode(fixture{"exec"}{"address"}.getStr)
  let db = ident("db")
  result = quote:
    block:
      var `db` = `vmState`.chaindb.getStateDB(`vmState`.blockHeader.stateRoot, `readOnly`)
      `handler`
      if `readOnly`:
        # This acts as a secondary check that no mutation took place for
        # read_only databases.
        assert `db`.rootHash == `vmState`.blockHeader.stateRoot
      elif `vmState`.blockHeader.stateRoot != `db`.rootHash:
        `vmState`.blockHeader.stateRoot = `db`.rootHash

      # TODO
      # `vmState`.accessLogs.reads.update(`db`.db.accessLogs.reads)
      # `vmState`.accessLogs.writes.update(`db`.db.accessLogs.writes)

      # remove the reference to the underlying `db` object to ensure that no
      # further modifications can occur using the `State` object after
      # leaving the context.
      # TODO `db`.db = nil
      # state._trie = None
