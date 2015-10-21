{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent.STM

import Yesod

import Dispatch ()
import Foundation

main :: IO ()
main = do
    tfilenames <- atomically $ newTVar []
    warp 5000 $ App tfilenames
