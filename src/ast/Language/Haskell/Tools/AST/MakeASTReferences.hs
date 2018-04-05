{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TemplateHaskellQuotes #-}

-- | Contains a transformation to alter the references generated by the template haskell 
-- function @makeReferences@.
module Language.Haskell.Tools.AST.MakeASTReferences where

import Control.Reference ((&))
import Language.Haskell.TH
import Language.Haskell.Tools.AST.Ann (Ann, element)

-- | Change the generated references to have the context of an annotated element.
-- Modifies the types according to the changes. This trasformation makes all
-- generated references monomorphic.
toASTReferences :: Q [Dec] -> Q [Dec]
toASTReferences = fmap (map $ \case
  SigD name (ForallT vars ctx (refType `AppT` (ctxOrig `AppT` dom `AppT` stage) 
                                       `AppT` _
                                       `AppT` fldOrig
                                       `AppT` _))
    -> SigD name (ForallT vars ctx (refType `AppT` (ConT ''Ann `AppT` ctxOrig `AppT` dom `AppT` stage) 
                                            `AppT` (ConT ''Ann `AppT` ctxOrig `AppT` dom `AppT` stage) 
                                            `AppT` fldOrig
                                            `AppT` fldOrig))
  ValD pat (NormalB e) locs -> ValD pat (NormalB (InfixE (Just (VarE 'element)) (VarE '(&)) (Just e))) locs
  d -> d)
