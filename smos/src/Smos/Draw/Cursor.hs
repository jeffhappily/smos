{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE OverloadedStrings #-}

module Smos.Draw.Cursor
    ( drawVerticalForestCursor
    , drawForestCursor
    , drawVerticalNonEmptyCursor
    , drawNonEmptyCursor
    ) where

import Brick.Types as B
import Brick.Widgets.Core as B

import Cursor.Forest
import Cursor.NonEmpty
import Cursor.Tree

drawVerticalForestCursor ::
       (TreeCursor a -> Widget n)
    -> (TreeCursor a -> Widget n)
    -> (TreeCursor a -> Widget n)
    -> ForestCursor a
    -> Widget n
drawVerticalForestCursor prevFunc curFunc nextFunc fc =
    drawVerticalNonEmptyCursor prevFunc curFunc nextFunc $
    forestCursorListCursor fc

drawForestCursor ::
       (TreeCursor a -> Widget n)
    -> (TreeCursor a -> Widget n)
    -> (TreeCursor a -> Widget n)
    -> ([Widget n] -> Widget n)
    -> ([Widget n] -> Widget n)
    -> (Widget n -> Widget n -> Widget n -> Widget n)
    -> ForestCursor a
    -> Widget n
drawForestCursor prevFunc curFunc nextFunc prevCombFunc nextCombFunc combFunc fc =
    drawNonEmptyCursor
        prevFunc
        curFunc
        nextFunc
        prevCombFunc
        nextCombFunc
        combFunc $
    forestCursorListCursor fc

drawVerticalNonEmptyCursor ::
       (a -> Widget n)
    -> (a -> Widget n)
    -> (a -> Widget n)
    -> NonEmptyCursor a
    -> Widget n
drawVerticalNonEmptyCursor prevFunc curFunc nextFunc =
    drawNonEmptyCursor
        prevFunc
        curFunc
        nextFunc
        B.vBox
        B.vBox
        (\a b c -> a <=> b <=> c)

drawNonEmptyCursor ::
       (a -> Widget n)
    -> (a -> Widget n)
    -> (a -> Widget n)
    -> ([Widget n] -> Widget n)
    -> ([Widget n] -> Widget n)
    -> (Widget n -> Widget n -> Widget n -> Widget n)
    -> NonEmptyCursor a
    -> Widget n
drawNonEmptyCursor prevFunc curFunc nextFunc prevCombFunc nextCombFunc combFunc NonEmptyCursor {..} =
    let prev = prevCombFunc $ map prevFunc $ reverse nonEmptyCursorPrev
        cur = curFunc nonEmptyCursorCurrent
        next = nextCombFunc $ map nextFunc nonEmptyCursorNext
     in combFunc prev cur next