{-# LANGUAGE DataKinds #-}

{- | This module contains functions to construct and submit comments.
-}

module Hintman.Comment
       ( submitReview
       ) where

import Data.Aeson (Value, encode)
import GitHub.Auth (Auth (..))
import GitHub.Data.Request (CommandMethod (Post), RW (RW), Request, command)
import GitHub.Request (executeRequest)

import Hintman.Core.PrInfo (Owner (..), PrNumber (..), Repo (..))
import Hintman.Core.Review (Comment (..), PullRequestReview (..), ReviewEvent (..))
import Hintman.Core.Token (GitHubToken (..))


{- | This function submits PR review according to the following API endpoint:

* https://developer.github.com/v3/pulls/reviews/#create-a-pull-request-review
-}
-- TODO: use PrInfo data type here
submitReview
    :: GitHubToken
    -> Owner
    -> Repo
    -> PrNumber
    -> [Comment]
    -> IO ()
submitReview (GitHubToken token) (Owner owner) (Repo repo) (PrNumber prNumber) comments = do
    response <- executeRequest (OAuth token) reviewCommand
    case response of
        Left err -> print err
        Right _  -> putStrLn "Success!"
  where
    reviewCommand :: Request 'RW Value
    reviewCommand = command
        Post
        ["repos", owner, repo, "pulls", show prNumber, "reviews"]
        (encode pullRequestReview)

    pullRequestReview :: PullRequestReview
    pullRequestReview = PullRequestReview
        { prrBody     = "Review by Hintman"  -- TODO: think about the text
        , prrEvent    = Commented  -- TODO: this can be configurable
        , prrComments = comments
        }
