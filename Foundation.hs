{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Foundation where

import Control.Concurrent.STM
import Data.ByteString.Lazy (ByteString)
import Data.Text (Text)
import qualified Data.Text as Text

import Yesod

data App = App (TVar [(Text, ByteString)])
instance Yesod App

instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

mkYesodData "App" $(parseRoutesFile "config/routes")

getList :: Handler [Text]
getList = do
    App tstate <- getYesod
    state <- liftIO $ readTVarIO tstate
    return $ map fst state

addFile :: App -> (Text, ByteString) -> Handler ()
addFile (App tstore) op =
    liftIO . atomically $ do
        modifyTVar tstore $ \ ops -> op : ops

getById :: Text -> Handler ByteString
getById ident = do
    App tstore <- getYesod
    operations <- liftIO $ readTVarIO tstore
    case lookup ident operations of
        Nothing -> notFound
        Just bytes -> return bytes