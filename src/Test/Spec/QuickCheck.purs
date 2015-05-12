module Test.Spec.QuickCheck (
  quickCheckWithSeed,
  quickCheck',
  quickCheck
  ) where

import Data.Maybe
import Data.Array
import Data.String (joinWith)
import Control.Monad.Eff
import Control.Monad.Eff.Exception
import Control.Monad.Eff.Random (Random(), random)
import Test.Spec.QuickCheck
import qualified Test.QuickCheck as QC

-- | Runs a Testable with a random seed and 100 inputs.
quickCheck :: forall r p.
              (QC.Testable p) =>
              p ->
              QC.QC Unit
quickCheck = quickCheck' 100

-- | Runs a Testable with a random seed and the given number of inputs.
quickCheck' :: forall r p.
               (QC.Testable p) =>
               Number ->
               p ->
               QC.QC Unit
quickCheck' n prop = do
  seed <- random
  quickCheckWithSeed seed n prop

getErrorMessage :: QC.Result -> Maybe String
getErrorMessage (QC.Failed msg) = Just msg
getErrorMessage _ = Nothing

-- | Runs a Testable with a given seed and number of inputs.
quickCheckWithSeed :: forall r p.
                      (QC.Testable p) =>
                      Number ->
                      Number ->
                      p ->
                      QC.QC Unit
quickCheckWithSeed seed n prop = do
  seed <- random
  let results = QC.quickCheckPure seed n prop
  let msgs = mapMaybe getErrorMessage results

  if length msgs > 0
    then throwException $ error $ joinWith "\n  " msgs
    else return unit
