import std/[os, sets]

import lscolors/style

type
  Mode* = enum
    ## The input modes nimmm can be in
    MdNormal,
    MdInput,
    MdSearch,

  ModeInfo* = object
    case mode*: Mode
    of MdNormal, MdSearch: discard
    of MdInput:
      prompt*: string
      input*: string
      callback*: proc (input: string)

  Tab* = object
    ## Represents a tab
    cd*: string
    index*: int
    searchQuery*: string

  DirEntry* = object
    ## Represents an entry
    path*: string
    info*: FileInfo
    style*: Style

  ErrorKind* = enum
    ## Possible errors nimmm encounters during browsing files
    ErrNone,
    ErrCannotCd,
    ErrCannotShow,
    ErrCannotOpen,

  State* = object
    ## Represents a possible state of nimmm
    error*: ErrorKind
    tabs*: seq[Tab]
    currentTab*: int
    modeInfo*: ModeInfo
    showHidden*: bool
    entries*: seq[DirEntry]
    visibleEntriesMask*: seq[bool]
    visibleEntries*: seq[int]
    selected*: HashSet[string]

proc initState*(): State =
  ## Initializes the default startup state
  State(error: ErrNone,
        tabs: @[Tab(cd: getCurrentDir(), index: 0,
                    searchQuery: "")],
        currentTab: 0,
        showHidden: false,
        modeInfo: ModeInfo(mode: MdNormal),
        entries: @[],
        visibleEntriesMask: @[],
        visibleEntries: @[],
        selected: initHashSet[string]())

template currentIndex*(s: State): int =
  ## Gets the current index, basically sugar for getting the current index of
  ## the current tab
  s.tabs[s.currentTab].index

template `currentIndex=`*(s: var State, i: int) =
  ## Sets the current index, basically sugar for setting the current index of
  ## the current tab
  s.tabs[s.currentTab].index = i

template currentSearchQuery*(s: State): string =
  ## Gets the current search query
  s.tabs[s.currentTab].searchQuery

template `currentSearchQuery=`*(s: State, query: string) =
  ## Sets the current search query
  s.tabs[s.currentTab].searchQuery = query

template currentEntry*(s: State): DirEntry =
  ## Gets the current entry
  s.entries[s.visibleEntries[s.currentIndex]]

template empty*(s: State): bool =
  ## Returns whether there are no entries
  s.visibleEntries.len < 1
