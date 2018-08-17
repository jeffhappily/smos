{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE RecordWildCards #-}

module Smos.Cursor.Entry
    ( EntryCursor(..)
    , makeEntryCursor
    , emptyEntryCursor
    , rebuildEntryCursor
    , entryCursorSelectionL
    , EntryCursorSelection(..)
, entryCursorSelect
, entryCursorSelectHeader
, entryCursorSelectContents
, entryCursorSelectTimestamps
, entryCursorSelectProperties
, entryCursorSelectStateHistory
, entryCursorSelectTags
, entryCursorSelectLogbook
    ) where

import GHC.Generics (Generic)

import Data.Validity

import qualified Data.List.NonEmpty as NE
import qualified Data.Map as M

import Lens.Micro

import Smos.Data.Types

import Smos.Cursor.Contents
import Smos.Cursor.Header
import Smos.Cursor.Logbook
import Smos.Cursor.Properties
import Smos.Cursor.StateHistory
import Smos.Cursor.Tags
import Smos.Cursor.Timestamps

data EntryCursor = EntryCursor
    { entryCursorHeaderCursor :: HeaderCursor
    , entryCursorContentsCursor :: Maybe ContentsCursor
    , entryCursorTimestampsCursor :: Maybe TimestampsCursor
    , entryCursorPropertiesCursor :: Maybe PropertiesCursor
    , entryCursorStateHistoryCursor :: Maybe StateHistoryCursor
    , entryCursorTagsCursor :: Maybe TagsCursor
    , entryCursorLogbookCursor :: LogbookCursor
    , entryCursorSelected :: EntryCursorSelection
    } deriving (Show, Eq, Generic)

instance Validity EntryCursor

makeEntryCursor :: Entry -> EntryCursor
makeEntryCursor Entry {..} =
    EntryCursor
        { entryCursorHeaderCursor = makeHeaderCursor entryHeader
        , entryCursorContentsCursor = makeContentsCursor <$> entryContents
        , entryCursorTimestampsCursor =
              makeTimestampsCursor <$> NE.nonEmpty (M.toList entryTimestamps)
        , entryCursorPropertiesCursor =
              makePropertiesCursor <$> NE.nonEmpty (M.toList entryProperties)
        , entryCursorTagsCursor = makeTagsCursor <$> NE.nonEmpty entryTags
        , entryCursorStateHistoryCursor =
              makeStateHistoryCursor <$>
              NE.nonEmpty (unStateHistory entryStateHistory)
        , entryCursorLogbookCursor = makeLogbookCursor entryLogbook
        , entryCursorSelected = WholeEntrySelected
        }

emptyEntryCursor :: EntryCursor
emptyEntryCursor = makeEntryCursor emptyEntry

rebuildEntryCursor :: EntryCursor -> Entry
rebuildEntryCursor EntryCursor {..} =
    Entry
        { entryHeader = rebuildHeaderCursor entryCursorHeaderCursor
        , entryContents = rebuildContentsCursor <$> entryCursorContentsCursor
        , entryTimestamps =
              maybe M.empty (M.fromList . NE.toList) $
              rebuildTimestampsCursor <$> entryCursorTimestampsCursor
        , entryProperties =
              maybe M.empty (M.fromList . NE.toList) $
              rebuildPropertiesCursor <$> entryCursorPropertiesCursor
        , entryStateHistory =
              StateHistory $
              maybe [] NE.toList $
              rebuildStateHistoryCursor <$> entryCursorStateHistoryCursor
        , entryTags =
              maybe [] NE.toList $ rebuildTagsCursor <$> entryCursorTagsCursor
        , entryLogbook = rebuildLogbookCursor entryCursorLogbookCursor
        }

entryCursorSelectionL :: Lens' EntryCursor EntryCursorSelection
entryCursorSelectionL =
    lens entryCursorSelected $ \ec s -> ec {entryCursorSelected = s}

entryCursorSelect :: EntryCursorSelection -> EntryCursor -> EntryCursor
entryCursorSelect ecl ec = ec & entryCursorSelectionL .~ ecl

entryCursorSelectHeader :: EntryCursor -> EntryCursor
entryCursorSelectHeader = entryCursorSelect HeaderSelected

entryCursorSelectContents :: EntryCursor -> EntryCursor
entryCursorSelectContents = entryCursorSelect ContentsSelected

entryCursorSelectTimestamps :: EntryCursor -> EntryCursor
entryCursorSelectTimestamps = entryCursorSelect TimestampsSelected

entryCursorSelectProperties :: EntryCursor -> EntryCursor
entryCursorSelectProperties = entryCursorSelect PropertiesSelected

entryCursorSelectStateHistory :: EntryCursor -> EntryCursor
entryCursorSelectStateHistory = entryCursorSelect StateHistorySelected

entryCursorSelectTags :: EntryCursor -> EntryCursor
entryCursorSelectTags = entryCursorSelect TagsSelected

entryCursorSelectLogbook :: EntryCursor -> EntryCursor
entryCursorSelectLogbook = entryCursorSelect LogbookSelected

data EntryCursorSelection
    = WholeEntrySelected
    | HeaderSelected
    | ContentsSelected
    | TimestampsSelected
    | PropertiesSelected
    | StateHistorySelected
    | TagsSelected
    | LogbookSelected
    deriving (Show, Eq, Generic)

instance Validity EntryCursorSelection
