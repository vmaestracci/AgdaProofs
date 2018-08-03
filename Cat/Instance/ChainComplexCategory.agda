{-# OPTIONS --cubical #-}
module Cat.Instance.ChainComplexCategory where

  open import Agda.Primitive --lsuc etc...
  
  open import Cubical.PathPrelude 
  open import Cubical.Lemmas
  open import Cubical.SigmaDirect

  open import Cubical.NType.Properties
  
  open import Cat.Category
  open import Cat.Equivalence
  open import Cat.Prelude --hiding (_×_) --using

  open import Utils
  open import complexes2

  open import Cubical.FromStdLib renaming (_+_ to _+ℕ_) hiding(Σ-syntax)
  open import Data.Integer.Base renaming (_+_ to _+d_) hiding (_⊔_) renaming (suc to sucℤ) renaming (pred to predℤ) renaming (+_ to pos) renaming (-[1+_] to negsuc)

  open import Cat.Category.ZeroCategory

  open import Cat.Instance.IntCategory
  
  module ChainMapM (ℓa ℓb : Level) (catZ : ZeroCategory ℓa ℓb) where

    open ZeroCategory catZ
    
    module _ (c1 c2 : ChainComplex ℓa ℓb {cat = catZ}) where

      record ChainMap  : Set (ℓa ⊔ ℓb) where
    
        field
          fn : (n : ℤ) → Arrow (c1 .ChainComplex.thisO n) (c2 .ChainComplex.thisO n)

        private
          cmtType = λ (n : ℤ) → ((fn (predℤ n)) <<< (c1 .ChainComplex.thisA n) ≡ ((c2 .ChainComplex.thisA n) <<< (fn n)))

        field
          commute : (n : ℤ) → (cmtType n)
          

    module _ {c1 c2 : ChainComplex ℓa ℓb {cat = catZ}} where

      open ChainMap

      setCMSq :
        let tfn = (n : ℤ) → Arrow (c1 .ChainComplex.thisO n) (c2 .ChainComplex.thisO n) in
        let tcomm = λ (fn : tfn) → ((n : ℤ) → (fn (predℤ n)) <<< (c1 .ChainComplex.thisA n) ≡ ((c2 .ChainComplex.thisA n) <<< (fn n))) in
        {sA : hasSquares (tfn)}{sB : ((fn : tfn) → hasSquares (tcomm fn))} → hasSquares (ChainMap c1 c2)

      setCMSq {sA} {sB} p0 p1 q0 q1 i j .fn n = {!!}
      setCMSq {sA} {sB} p0 p1 q0 q1 i j .commute n = {!!}
      
      
      ChainMap≡ : {a b : ChainMap c1 c2} → a .fn ≡ b .fn → a ≡ b
      ChainMap.fn      (ChainMap≡ p i) = p i
      ChainMap.commute (ChainMap≡ {a} {b} p i) = λ n → lemPropF (λ f → arrowsAreSets {A = (ChainComplex.thisO c1 n)} {B = (c2 .ChainComplex.thisO (predℤ n))} (f (predℤ n) <<< c1 .ChainComplex.thisA n) (c2 .ChainComplex.thisA n <<< f n)) p {b0 = a .commute n} {b1 = b .commute n} i


    module _ {c : ChainComplex ℓa ℓb {cat = catZ}} where

      open ChainComplex

      idChainMap : (ChainMap c c)

      ChainMap.fn      (idChainMap) = λ n → catZ .ZeroCategory.identity {A = (c .thisO n)}
      ChainMap.commute (idChainMap) = λ n → begin  
          identity <<< c .thisA n       ≡⟨ fst (catZ .ZeroCategory.isIdentity) ⟩
          c .thisA n                    ≡⟨ sym ( snd (catZ .ZeroCategory.isIdentity)) ⟩
          c .thisA n <<< identity ∎

    module Tilde (catZ : ZeroCategory ℓa ℓb) where

      open ZeroCategory catZ

      thisOt = ℤ → (catZ .Object)
        
      thisAt : (to : thisOt) → Set ℓb
      thisAt = λ to → (i : ℤ) → (catZ .Arrow) (to i) (to (predℤ i))

      ~ : Σ[ to ∈ thisOt ] (thisAt to → {!IntFunc.IntFunc catZ!})
      ~ = {!!}

      isEquiv-~ : isEquiv {!!} {!!} {!!}
      isEquiv-~ = {!!}


  module ChainComplexCategoryM (ℓa ℓb : Level) (catZ : ZeroCategory ℓa ℓb) where

    open Category using (raw ; isCategory)
    open RawCategory using (Object ; identity ; _≊_) --≊
    open IsCategory using (isPreCategory ; univalent)
    open IsPreCategory using (isAssociative ; isIdentity ; arrowsAreSets)
    
    open ChainMapM ℓa ℓb catZ
    open ChainMap
    open ChainComplex

    assoc = catZ .ZeroCategory.c .Category.isCategory .IsCategory.isPreCategory .IsPreCategory.isAssociative

    open ZeroCategory catZ

    ChainComplexCategory : Category (ℓa ⊔ ℓb) (ℓa ⊔ ℓb)

    ChainComplexCategory .raw .Object = ChainComplex ℓa ℓb {cat = catZ}
    ChainComplexCategory .raw .RawCategory.Arrow = λ x y → ChainMap x y
    ChainComplexCategory .raw .identity {A} = idChainMap {c = A}
    
    ChainComplexCategory .raw .RawCategory._<<<_ {A} {B} {C} bc ab .fn n = bc .fn n <<< ab .fn n
    ChainComplexCategory .raw .RawCategory._<<<_ {A} {B} {C} bc ab .commute n =  begin
    
      bc .fn (predℤ n) <<< ab .fn (predℤ n) <<< A .thisA n ≡⟨ sym (assoc) ⟩
      bc .fn (predℤ n) <<< (ab .fn (predℤ n) <<< A .thisA n) ≡⟨ (ab .commute n <| λ x → bc .fn (predℤ n) <<< x) ⟩
      bc .fn (predℤ n) <<< ((B .thisA n)  <<< (ab .fn n)) ≡⟨ assoc ⟩
      bc .fn (predℤ n) <<< (B .thisA n)  <<< (ab .fn n) ≡⟨ (bc .commute n <| λ x → x <<< (ab .fn n)) ⟩
      C .thisA n <<< bc .fn n <<< ab .fn n ≡⟨ sym (assoc) ⟩
      C .thisA n <<< (bc .fn n <<< ab .fn n) ∎


    ChainComplexCategory .isCategory .isPreCategory .isAssociative {A} {B} {C} {D} {f} {g} {h} = ChainMap≡ (funExt λ x → catZ .isAssociative)
    ChainComplexCategory .isCategory .isPreCategory .isIdentity {A} {B} {c} = ChainMap≡ (funExt (λ x → fst (catZ .isIdentity))) , ChainMap≡ (funExt (λ x → snd (catZ .isIdentity)))

    --       {-- Three way to prove that :

    --         - Directly; repeationg the proof for Σs. (& Adapting Cubical.Sigma)
    --         - Transforming the record in a Σ back and forth. (& Cubical.Sigma)
    --         - Directly, but using Squares instead of sets. (& Adapting Cubical.DirectSigma, it was done above)

    --       --}

    ChainComplexCategory .isCategory .isPreCategory .arrowsAreSets {A} {B} =
      square-isSet (setCMSq {sA = psA} {sB = psB})
      
      where
        psA : hasSquares ((n : ℤ) → Arrow (A .thisO n) (B .thisO n))
        psA = isSet-square (setPi λ x → catZ .arrowsAreSets)
        
        psB : (fn : (n : ℤ) → Arrow (A .thisO n) (B .thisO n)) → hasSquares ((n : ℤ) → fn (predℤ n) <<< A .thisA n ≡ B .thisA n <<< fn n)
        psB fn = isSet-square (setPi λ x → propSet (catZ .arrowsAreSets (fn (predℤ x) <<< A .thisA x) (B .thisA x <<< fn x)))
        

    ChainComplexCategory .isCategory .univalent {A} {B} = {!univalenceFrom≃ !} --univalenceFrom≃ (transEq (transEq lemma1 lemma2) lemma3)
      --univalenceFrom≃ (transEq (transEq lemma1 lemma2) lemma3)
      --transEq (transEq lemma1 lemma2) lemma3 .snd
      where


        -- -- Lemma 1.
        -- ---
        -- ---
        
        -- stype = Σ (A .thisO ≡ B .thisO) (λ eq → Σ ((λ j → (p : ℤ) → Arrow (eq j p) (eq j (predℤ p)))[ A .thisA ≡ B .thisA ]) (λ eq' → ((λ j → (i : ℤ) → (eq' j) (predℤ i) <<< (eq' j) i ≡ zeroFunc (eq j i) (eq j (predℤ (predℤ i)))) [ A .isChain ≡ B .isChain ])) )

        -- lr1 = (λ w → (λ j p → (w j) .thisO p) , ((λ j p → (w j) .thisA p) , λ j i → (w j) .isChain i)) --w for witness
        -- rl1 = λ esig j → record { thisO = esig .fst j ; thisA = esig .snd .fst j ; isChain = esig .snd .snd j }

        -- ll1 = λ (x : A ≡ B) → refl

        -- rr1 = λ (y : stype) → refl
        
        -- lemma1 : (A ≡ B) ≃ stype
        
        -- lemma1 .fst = lr1
        -- lemma1 .snd = gradLemma lr1 rl1 rr1 ll1

        -- -- Lemma 2.
        -- ---
        -- ---
        
        -- stype2 =  Σ (A .thisO ≡ B .thisO) (λ eq → (λ j → (p : ℤ) → Arrow (eq j p) (eq j (predℤ p)))[ A .thisA ≡ B .thisA ])

        -- lr : stype → stype2
        -- lr esig .fst j = esig .fst j
        -- lr esig .snd j = esig .snd .fst j



        
        -- thisOt = ℤ → (catZ .Object)
        
        -- thisAt : (to : thisOt) → Set ℓb
        -- thisAt = λ to → (i : ℤ) → Arrow (to i) (to (predℤ i))

        -- isChaint : (to : ℤ → (catZ .Object)) (ta : (i : ℤ) → Arrow (to i) (to (predℤ i))) → Set ℓb
        -- isChaint to ta = (i : ℤ) → (ta (predℤ i)) <<< (ta i) ≡ zeroFunc (to i) (to (predℤ (predℤ i)))



        -- -- Proving that isChain is a proposition.
        -- isProp-isChain : ∀ to ta → isProp (isChaint to ta)
        -- isProp-isChain to ta = propPi λ p → catZ .arrowsAreSets ((ta (predℤ p) <<< ta p)) (zeroFunc (to p) (to (predℤ (predℤ p))))

        -- --The equality is thus contractible :
        -- isContr-eqisChain :  ∀ to ta → (x y : (isChaint to ta)) → isContr (x ≡ y)
        -- isContr-eqisChain to ta x y = hasLevelPath ⟨-2⟩ (isProp-isChain to ta) x y

        -- --And thus has a center:
        -- center :  ∀ to ta → (x y : (isChaint to ta)) → (x ≡ y)
        -- center to ta x y = isContr-eqisChain to ta x y .fst

        -- --Thus the depent type has a center
        -- center' : ∀ p1 p2 (eq : p1 ≡ p2) (x : isChaint (eq i0 .fst) (eq i0 .snd)) (y : isChaint (eq i1 .fst) (eq i1 .snd)) → PathP ((λ j → (i : ℤ) → (eq j .snd (predℤ i)) <<< (eq j .snd i) ≡ zeroFunc (eq j .fst i) (eq j .fst (predℤ (predℤ i))))) x y
        -- center' p1 = pathJ _
        --   λ x y → center (p1 .fst) (p1 .snd) x y

        -- rl : stype2 → stype
        -- rl est .fst j = est .fst j
        -- rl est .snd .fst j = est .snd j
        -- rl est .snd .snd = center' ((A .thisO) , (A .thisA)) ((B .thisO) , (B .thisA)) (λ j → est .fst j , est .snd j) (A .isChain) (B .isChain)
        -- --lemPropF (λ e → isProp-isChain (e .fst) (e .snd)) (λ i → (est .fst i), (est .snd .fst i)) {b0 = A .isChain} {b1 = B .isChain}

        -- rr : (y : stype2) → lr (rl y) ≡ y
        -- rr y = refl

        -- isProp-eqisChain : ∀ to ta → (x y : (isChaint to ta)) → isProp (x ≡ y)
        -- isProp-eqisChain to ta x y = HasLevel+1 ⟨-2⟩ (isContr-eqisChain to ta x y)

        -- -- From an isProp on something dependant, we can get an equality between every dependant equality.
        -- module Lemma {ℓ} {ℓ'} (A : Set ℓ) (B : A → Set ℓ') (pB : ∀ x → isProp (B x)) where

        --   lemma : (x y : A) → (eq : x ≡ y) → (b0 : B x) (b1 : B y) → (eq1 eq2 : PathP (\ i → B (eq i)) b0 b1) → eq1 ≡ eq2
        --   lemma x = pathJ _ \ b0 b1 → HasLevel+1 ⟨-2⟩ (hasLevelPath ⟨-2⟩ (pB x) b0 b1)
        
        -- ll : (x : stype) → rl (lr x) ≡ x
        -- ll x j .fst = x .fst
        -- ll x j .snd .fst i = x .snd .fst i
        -- ll est j .snd .snd = (begin    --Actually all the proofs are equals...
        --   ((rl (lr est)) .snd .snd) ≡⟨ Lemma.lemma (Σ thisOt (λ eq → thisAt eq)) (λ e → isChaint (e .fst) (e .snd)) (λ e → isProp-isChain (e .fst) (e .snd))
        --                                            (A .thisO , A .thisA) (B .thisO , B .thisA) (λ j → (est .fst j) , (est .snd .fst j))
        --                                            (A .isChain) (B .isChain)
        --                                            (((rl (lr est)) .snd .snd)) ((est .snd .snd)) ⟩
        --   (est .snd .snd)  ∎) j
        

        -- lemma2 : stype ≃ stype2
        
        -- lemma2 .fst = lr
        -- lemma2 .snd = gradLemma lr rl rr ll
        
        -- -- Lemma 3.
        -- ---
        -- ---

        -- LemmaY : {A : ChainComplex ℓa ℓb {cat = catZ}} (B : ChainComplex ℓa ℓb {cat = catZ}) (p : A ≡ B)  → transp (λ j → (RawCategory.Arrow (ChainComplexCategory .raw)) (p j) (p j)) idChainMap ≡ idChainMap 
        -- LemmaY = pathJ _ (transp-refl idChainMap)

        
        -- toEq : stype2 → (raw ChainComplexCategory RawCategory.≊ A) B

        -- ---- Construct an Arrow from A to B (so a ChainMap)
        -- --stype2 =  Σ (A .thisO ≡ B .thisO) (λ eq → (λ j → (p : ℤ) → Arrow (eq j p) (eq j (predℤ p)))[ A .thisA ≡ B .thisA ])

        -- toEq eg .fst =
        --   let equal = (inverse lemma1 (inverse (lemma2) eg)) in
        --   transp (λ i → ChainMap A (equal i)) idChainMap

        -- toEq eg .snd .fst = 
        --   let equal = (inverse lemma1 (inverse (lemma2) eg)) in
        --   transp (λ i → ChainMap (equal i) A) idChainMap  -- Alt : | ChainMap B ((sym equal) i)) idChainMap

        -- toEq eg .snd .snd .fst =
        
        --   let equal = (inverse lemma1 (inverse (lemma2) eg)) in
        --   begin
        
        --    RawCategory._<<<_ (raw ChainComplexCategory)
        --   (transp (λ i →  ChainMap (equal i) A) idChainMap)
        --   (transp (λ i → ChainMap A (equal i)) idChainMap)

        --     ≡⟨ lemmaX (ChainComplexCategory .raw) A refl B equal A refl idChainMap idChainMap ⟩

        --    transp (λ j → ChainMap A A) ((RawCategory._<<<_ (raw ChainComplexCategory)) idChainMap idChainMap)

        --    ≡⟨ transp-refl ((RawCategory._<<<_ (raw ChainComplexCategory)) idChainMap idChainMap) ⟩ --isIdentity idChainMap and transp-iso

        --    ((RawCategory._<<<_ (raw ChainComplexCategory)) idChainMap idChainMap)

        --    ≡⟨ (isPreCategory (isCategory ChainComplexCategory)) .isIdentity .fst ⟩ --isIdentity idChainMap and transp-iso

        --   identity (raw ChainComplexCategory)  ∎
          
        -- toEq eg .snd .snd .snd =
        --   let equal = (inverse lemma1 (inverse (lemma2) eg)) in
        --   begin
        --     RawCategory._<<<_ (raw ChainComplexCategory)
        --     (transp (λ i → ChainMap A (equal i)) idChainMap)
        --     (transp (λ i → ChainMap (equal i) A) idChainMap)
            
        --       ≡⟨ lemmaX (ChainComplexCategory .raw) B equal A refl B equal idChainMap idChainMap ⟩

        --     transp
        --       (λ j → (RawCategory.Arrow (ChainComplexCategory .raw)) (equal j) (equal j))
        --       (RawCategory._<<<_ (ChainComplexCategory .raw) idChainMap idChainMap)

        --       ≡⟨ ((isPreCategory (isCategory ChainComplexCategory)) .isIdentity {f = idChainMap} .fst <| λ x → transp ((λ j → (RawCategory.Arrow (ChainComplexCategory .raw)) (equal j) (equal j))) x) ⟩
              
        --     transp
        --       (λ j →
        --          RawCategory.Arrow (ChainComplexCategory .raw)
        --          (equal j)
        --          (equal j))
        --       (idChainMap)

        --       ≡⟨ LemmaY B equal ⟩

        --     identity (raw ChainComplexCategory) ∎

        
        -- postulate a : (eq : Σ (RawCategory.Arrow (raw ChainComplexCategory) A B)
        --                       (RawCategory.Isomorphism (raw ChainComplexCategory))) → _

        -- eqTo : (raw ChainComplexCategory RawCategory.≊ A) B → stype2
        -- eqTo eq .fst = funExt λ x →
        --   let F = inverse ((idToIso (A .thisO x) (B .thisO x)) , (catZ .univalent {A = (A .thisO x)} {B = (B .thisO x)}))
        --       f = eq .fst .fn x
        --       g = eq .snd .fst .fn x

        --       idL : g <<< f ≡ catZ .identity
        --       idL = λ i → toSig (eq .snd .snd .fst) .fst i x
              
        --       idR : f <<< g ≡ catZ .identity
        --       idR = λ i → toSig (eq .snd .snd .snd) .fst i x
        --   in F (f , (g , (idL , idR)))
        --   where
        --     toSig : ∀ {c1 c2} → {C D : ChainMap c1 c2} (p : (C ≡ D)) → (Σ (C .fn ≡ D .fn) (λ eq → (λ j → (p : ℤ) → (eq j) (predℤ p) <<< c1 .thisA p ≡ c2 .thisA p <<< (eq j) p )[ C .commute ≡ D .commute ]))
        --     toSig p = (λ j n → p j .fn n) , λ j n → p j .commute n

        -- eqTo eq .snd = a eq
        -- --eqTo eq .snd j p = {!(a p eq) j!}


        
        -- eqEq : (y : (raw ChainComplexCategory RawCategory.≊ A) B) → toEq (eqTo y) ≡ y
        -- eqEq y j .fst = {!!}
        -- eqEq y j .snd = {!!}

        -- toTo : (x : stype2) → eqTo (toEq x) ≡ x
        -- toTo x j .fst = {!x .fst i p!}
        -- toTo x j .snd = {!!}

        -- lemma3 : stype2 ≃ ((raw ChainComplexCategory RawCategory.≊ A) B)

        -- lemma3 .fst = toEq
        -- lemma3 .snd = gradLemma toEq eqTo eqEq toTo


















        -- -- -- -- Proof that A ≡ B with an element of stype
        -- -- -- lemma1 .snd .equiv-proof esig .fst .fst j .thisO p   = esig .fst j p
        -- -- -- lemma1 .snd .equiv-proof esig .fst .fst j .thisA p   = esig .snd .fst j p
        -- -- -- lemma1 .snd .equiv-proof esig .fst .fst j .isChain p = esig .snd .snd j p


        -- -- -- -- The fiber thingy...
        -- -- -- lemma1 .snd .equiv-proof esig .fst .snd = refl

        -- -- -- lemma1 .snd .equiv-proof esig .snd y  = {!!}
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .fst = {!fiber!} 
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .fst i .thisO p = {!!}
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .fst i .thisA p = {!!}
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .fst i .isChain p = {!!}
        
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .snd = {!begin ?!}
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .snd i .fst = λ x x₁ → {!!}
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .snd i .snd .fst k p = {!!}
        -- -- -- lemma1 .snd .equiv-proof esig .snd y j .snd i .snd .snd k p l = {!!}


        -- -- -- -- --- Proof of lemma 2
        -- -- -- -- ---
        -- -- -- -- lemma2 : stype ≃ stype2 --We can get rid of the second part.
        -- -- -- -- lemma2 .fst esig .fst j p = esig .fst j p
        -- -- -- -- lemma2 .fst esig .snd j p = esig .snd .fst j p

        -- -- -- -- --The is-equiv part

        -- -- -- -- -- fiber (fst lemma2) esig2
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .fst .fst .fst j p = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .fst .fst .snd .fst j p = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .fst .fst .snd .snd j p = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .fst .snd j .fst i p = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .fst .snd j .snd i p = {!!}

        -- -- -- -- --(y : fiber (fst lemma2) esig2) → fst (lemma2 .snd .equiv-proof esig2) ≡ y
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .snd fib j .fst .fst i p = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .snd fib j .fst .snd .fst = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .snd fib j .fst .snd .snd = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .snd fib j .snd x .fst i p = {!!}
        -- -- -- -- lemma2 .snd .equiv-proof esig2 .snd fib j .snd x .snd i p = {!!}




        -- -- -- -- -- --- Proof of lemma 3
        -- -- -- -- -- ---
        -- -- -- -- -- lemma3 : {!!} --We use the fact that catZ is univalent to proove that the equality between thisO is an equivalence - Same for thisA
        -- -- -- -- -- lemma3 = {!!}

        -- -- -- -- -- lemma4 : {!!} -- We do everythin in reverse
        -- -- -- -- -- lemma4 = {!!}
        

    
    
