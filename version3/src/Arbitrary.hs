module Arbitrary where

import Test.QuickCheck
    ( elements, frequency, sized, Arbitrary(arbitrary), Gen ) 
import qualified Test.QuickCheck as QC

import Syntax
import PrettyPrint
import Parser

import qualified Unbound.Generics.LocallyNameless as Unbound

bindSize :: Int
bindSize = 1

prop_roundtrip :: Term -> Bool
prop_roundtrip tm = 
    case parseExpr (render (disp tm))  of
        Left _ -> False
        Right tm' -> Unbound.aeq tm tm' 
           
quickCheckN :: QC.Testable prop => Int -> prop -> IO ()
quickCheckN n = QC.quickCheckWith $ QC.stdArgs { QC.maxSuccess = n , QC.maxSize = 100 }

sampleName :: IO ()
sampleName = QC.sample' (arbitrary :: Gen TName) >>= 
    mapM_ (print . render . disp)

sampleTerm :: IO ()
sampleTerm = QC.sample' (arbitrary :: Gen Term) >>= 
    mapM_ (print . render . disp)


-- variable names that are not reserved words
genName :: Gen (Unbound.Name a)
genName = Unbound.string2Name <$> elements ["x", "y", "z", "x0" , "y0"]



instance Arbitrary (Unbound.Name a) where
    arbitrary = genName where
        
instance Arbitrary Epsilon where
    arbitrary = elements [ Runtime, Erased ]


instance Arbitrary Arg where
    arbitrary = sized genArg
    shrink (Arg ep  tm) = [ Arg ep  tm' | tm' <- QC.shrink tm]

genArg :: Int -> Gen Arg
genArg n = Arg <$> arbitrary <*>  genTerm (n `div` 2)

genArgs :: Int -> Gen [Arg]
genArgs n = QC.listOf (genArg n)

base :: Gen Term
base = elements [Type, 
                TrustMe, PrintMe, 
                TyUnit, LitUnit, TyBool, 
                LitBool True, LitBool False {- SOLN EQUAL -}, Refl {- STUBWITH -} ]

genTerm :: Int -> Gen Term
genTerm n 
        | n <= 1 = base
        | otherwise = 
            frequency [

              (1, Var <$> genName),
              (1, genLam n'),
              (1, App <$> genTerm n' <*> genArg n'),
              (1, genPi n'),
              (1, Ann <$> genTerm n' <*> genTerm n'),
              (1, Paren <$> genTerm n'),
              (1, Pos internalPos <$> genTerm n'),
              (1, genLet n'),
              (1, If <$> genTerm n' <*> genTerm n' <*> genTerm n'),
              (1, genSigma n'),
              (1, Prod <$> genTerm n' <*> genTerm n'),
              (1, genLetPair n'),
                            (1, TyEq <$> genTerm n' <*> genTerm n'),
              (1, Subst <$> genTerm n' <*> genTerm n'),
              (1, Contra <$> genTerm n'),
              
              
              (1, base)
            ]
    where n' = n `div` 2

genLam :: Int -> Gen Term
genLam n = do 
    p <- ( (,) <$> genName <*> arbitrary ) 
    
    b <- genTerm n
    return $ Lam (Unbound.bind p b)

genPi :: Int -> Gen Term
genPi n = do 
    p <- ((,,) <$> genName <*> arbitrary <*> (Unbound.Embed <$> genTerm n))
    
    tyB <- genTerm n
    return $ Pi (Unbound.bind p tyB)

genSigma :: Int -> Gen Term
genSigma n = do
    p <- ((,) <$> genName <*> (Unbound.Embed <$> genTerm n))
    tyB <- genTerm n
    return $ Sigma (Unbound.bind p tyB)

genLet :: Int -> Gen Term 
genLet n = do
    p <- ( (,) <$> genName <*> (Unbound.Embed <$> genTerm n') ) 
    b <- genTerm n'
    return $ Let (Unbound.bind p b)
  where n' = n `div` 2

genLetPair :: Int -> Gen Term 
genLetPair n = do
    p <- ( (,) <$> genName <*> genName ) 
    a <- genTerm n'
    b <- genTerm n'
    return $ LetPair a (Unbound.bind p b)
  where n' = n `div` 2



instance Arbitrary Term where
    arbitrary = sized genTerm where
    shrink (App tm arg) = 
        [tm, unArg arg] ++ [App tm' arg | tm' <- QC.shrink tm] ++ [App tm arg' | arg' <- QC.shrink arg]
    shrink (Ann tm ty) = [tm] ++ [Ann tm' ty | tm' <- QC.shrink tm]
    shrink (Paren tm) = [tm] ++ [Paren tm' | tm' <- QC.shrink tm]
    shrink _ = []
       

