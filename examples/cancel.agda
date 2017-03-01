module cancel where

open import Function

open import Translate
open import Translate.Combinatorics
open import Translate.Support
-- open import Translate.EqReasoning
open import Translate.Axioms
open import Translate.Bijection using (getTo; getFrom; getToFrom; getFromTo)
open import Translate.Tools
import Relation.Binary.PropositionalEquality
import Data.Nat.Properties.Simple as NPS

open import Data.Product

suc-inj : ∀ {a b} → ℕsuc a P≡ ℕsuc b → a P≡ b
suc-inj Prefl = Prefl

inj₁-inj : ∀ {l l2} {A : Set l} {B : Set l2} {a b : A} → inj₁ {l} {l2} {A} {B} a P≡ inj₁ b → a P≡ b
inj₁-inj Prefl = Prefl

inj₂-inj : ∀ {l l2} {A : Set l} {B : Set l2} {a b : B} → inj₂ {l} {l2} {A} {B} a P≡ inj₂ b → a P≡ b
inj₂-inj Prefl = Prefl

apply-with-proof : ∀ {l} {a b : Set l} → (f : a → b) → (x : a) → Σ b (λ y → f x P≡ y)
apply-with-proof f x = f x , Prefl

open Relation.Binary.PropositionalEquality.≡-Reasoning

-- absurd : ∀ {l} {a : Set l} → ⊥ → a
-- absurd ()

-- suc-cancel : ∀ {a b} → suc a ≡ suc b → a ≡ b
-- suc-cancel {a} {b} p with toEquality p | toBijection p
-- suc-cancel {a} {b} p | eq | mkBij to from x x₁
--   = axiom (suc-inj eq) (mkBij to' from' {!!} {!!})
--     where
--       contr : ∀ {x y} → to x P≡ nothing → to y P≡ nothing → ⊥
--       contr p₁ p₂ = {!!}

--       to' : lift a → lift b
--       to' x with apply-with-proof to (just x)
--       to' x | just y , p₁ = y
--       to' x | nothing , p₁ with apply-with-proof to nothing
--       to' x | nothing , p₁ | just y , p₂ = y
--       to' x | nothing , p₁ | nothing , p₂ = absurd (contr p₁ p₂)

--       from' : lift b → lift a
--       from' x = {!!}


data [_∧_⊨_⇒_] {A B C D : Set} (b₁ : (A ⊎ B) B≡ (C ⊎ D)) (b₂ : B B≡ D) : (A ⊎ B) → C → Set where
  step : ∀ {p q r s} → (getTo b₁ p P≡ inj₂ q) → (getFrom b₂ q P≡ r) → [ b₁ ∧ b₂ ⊨ inj₂ r ⇒ s ] → [ b₁ ∧ b₂ ⊨ p ⇒ s ]
  done : ∀ {p q} → (getTo b₁ p P≡ inj₁ q) → [ b₁ ∧ b₂ ⊨ p ⇒ q ]

reverse : ∀ {A B C D} (b₁ : (A ⊎ B) B≡ (C ⊎ D)) (b₂ : B B≡ D) x y → [ b₁ ∧ b₂ ⊨ inj₁ x ⇒ y ] → [ (Bsym b₁) ∧ (Bsym b₂) ⊨ inj₁ y ⇒ x ]
reverse (mkBij to from toFrom fromTo) (mkBij to₁ from₁ toFrom₁ fromTo₁) x y (done p) = done (
    begin
      from (inj₁ y)
    ≡⟨ Pcong from (Psym p) ⟩
      from (to (inj₁ x))
    ≡⟨ fromTo (inj₁ x) ⟩
      inj₁ x
    ∎
  )
reverse b₁@(mkBij to₁ from₁ toFrom₁ fromTo₁)
        b₂@(mkBij to₂ from₂ toFrom₂ fromTo₂)
        x y (step {dp} {dq} {dr} {ds} p₁ p₂ p) = rev dr dq p₂ p (done (begin
          from₁ (inj₂ dq)
        ≡⟨ Pcong from₁ (Psym p₁) ⟩
          from₁ (to₁ (inj₁ x))
        ≡⟨ fromTo₁ (inj₁ x) ⟩
          inj₁ x
        ∎))
  where

    rev : ∀ z₁ z₂ → from₂ z₂ P≡ z₁ → [ b₁ ∧ b₂ ⊨ inj₂ z₁ ⇒ y ] → [ (Bsym b₁) ∧ (Bsym b₂) ⊨ inj₂ z₂ ⇒ x ] → [ (Bsym b₁) ∧ (Bsym b₂) ⊨ inj₁ y ⇒ x ]
    rev z₁ z₂ zp (done p) q = step
      (begin
        from₁ (inj₁ y)
      ≡⟨ Pcong from₁ (Psym p) ⟩
        from₁ (to₁ (inj₂ z₁))
      ≡⟨ fromTo₁ (inj₂ z₁) ⟩
        inj₂ z₁
      ∎)
      (begin
        to₂ z₁
      ≡⟨ Pcong to₂ (Psym zp) ⟩
        to₂ (from₂ z₂)
      ≡⟨ toFrom₂ z₂ ⟩
        z₂
      ∎)
      q

    rev z₁ z₂ zp (step {dp} {dq} {dr} {ds} p₁ p₂ p) q = rev dr dq p₂ p (step
      (begin
        from₁ (inj₂ dq)
      ≡⟨ Pcong from₁ (Psym p₁) ⟩
        from₁ (to₁ (inj₂ z₁))
      ≡⟨ fromTo₁ (inj₂ z₁) ⟩
        inj₂ z₁
      ∎)
      (begin
        to₂ z₁
      ≡⟨ Pcong to₂ (Psym zp) ⟩
        to₂ (from₂ z₂)
      ≡⟨ toFrom₂ z₂ ⟩
        z₂
      ∎)
      q)

bijective : ∀ {A B C D} (b₁ : (A ⊎ B) B≡ (C ⊎ D)) (b₂ : B B≡ D) x y z → [ b₁ ∧ b₂ ⊨ y ⇒ x ] → [ b₁ ∧ b₂ ⊨ y ⇒ z ] → x P≡ z
bijective (mkBij to₁ from₁ toFrom₁ fromTo₁)
          (mkBij to₂ from₂ toFrom₂ fromTo₂)
          x y z (done p) (done q) =
  inj₁-inj (begin
      inj₁ x
    ≡⟨ Psym p ⟩
      to₁ y
    ≡⟨ q ⟩
      inj₁ z
    ∎)
bijective b₁@(mkBij to₁ from₁ toFrom₁ fromTo₁)
          b₂@(mkBij to₂ from₂ toFrom₂ fromTo₂)
          x y z
          (step {pp} {pq} {pr} {ps} p₁ p₂ p)
          (step {qp} {qq} {qr} {qs} q₁ q₂ q) = bijective b₁ b₂ x (inj₂ qr) z (fix p) q
  where
    fix : [ b₁ ∧ b₂ ⊨ inj₂ pr ⇒ x ] → [ b₁ ∧ b₂ ⊨ inj₂ qr ⇒ x ]
    fix t rewrite (begin
        qr
      ≡⟨ Psym q₂ ⟩
        from₂ qq
      ≡⟨ Pcong from₂ (inj₂-inj (begin
                                inj₂ qq
                               ≡⟨ Psym q₁ ⟩
                                to₁ y
                               ≡⟨ p₁ ⟩
                                inj₂ pq
                               ∎)) ⟩
        from₂ pq
      ≡⟨ p₂ ⟩
        pr
      ∎) = t

bijective (mkBij to₁ from₁ toFrom₁ fromTo₁) (mkBij to₂ from₂ toFrom₂ fromTo₂) x y z (done p) (step {dp} {dq} {dr} {ds} q₁ q₂ q) with Ptrans (Psym p) q₁
... | ()
bijective (mkBij to₁ from₁ toFrom₁ fromTo₁) (mkBij to₂ from₂ toFrom₂ fromTo₂) x y z (step p₁ p₂ p) (done q) with Ptrans (Psym p₁) q
... | ()

-- iter : ∀ {A B C D : Set} → (b₁ : (A ⊎ B) B≡ (C ⊎ D)) → (b₂ : B B≡ D) → (x : A ⊎ B) → Σ C (λ y → [ b₁ ∧ b₂ ⊨ x ⇒ y ])
-- iter b₁ b₂ x = {!!} -- y , end p Prefl
-- iter b₁ b₂ x = ? -- with apply-with-proof (getFrom b₂) y
-- iter b₁ b₂ x (inj₂ y) p | z , zp = iter b₁ b₂ x (getTo b₁ (inj₂ z)) (step p zp Prefl)

-- XXX: Should this be TERMINATING?
-- TODO: Use that "decreasing" datatype to show that this is terminating
{-# NON_TERMINATING #-}
run : ∀ {A B C D : Set} → (b₁ : (A ⊎ B) B≡ (C ⊎ D)) → (b₂ : B B≡ D) → (x : A ⊎ B) → Σ C (λ y → [ b₁ ∧ b₂ ⊨ x ⇒ y ])
run b₁ b₂ x with apply-with-proof (getTo b₁) x
run b₁ b₂ x | inj₁ y , yp = y , done yp
run b₁ b₂ x | inj₂ y , yp with run b₁ b₂ (inj₂ (getFrom b₂ y))
run b₁ b₂ x | inj₂ y , yp | (z , zp) = z , step yp Prefl zp

-- bijective : ∀ {A B C D} (b₁ : (A ⊎ B) B≡ (C ⊎ D)) b₂ x y z → [ b₁ ∧ b₂ ⊨ inj₁ x ⇒ y ] → [ (Bsym b₁) ∧ (Bsym b₂) ⊨ inj₁ y ⇒ z ] → x P≡ z
-- bijective b₁@(mkBij to₁ from₁ toFrom₁ fromTo₁)
--           b₂@(mkBij to₂ from₂ toFrom₂ fromTo₂)
--           x y z (step {dp₁} {dq₁} {dr₁} {ds₁} p₁ p₂ p) (step {dp₂} {dq₂} {dr₂} {ds₂} q₁ q₂ q)
--           =
--           let meow = bijective b₁ b₂ {!!} {!!} {!!} {!!} {!!}
--           in inj₁-inj (
--             begin
--               inj₁ x
--             ≡⟨ Psym (fromTo₁ (inj₁ x)) ⟩
--               from₁ (to₁ (inj₁ x))
--             ≡⟨ Pcong from₁ p₁ ⟩
--               from₁ (inj₂ dq₁)
--             ≡⟨ {!!} ⟩
--               from₁ (to₁ (inj₁ z))
--             ≡⟨ fromTo₁ (inj₁ z) ⟩
--               inj₁ z
--             ∎
--           )

-- -- x P≡ z

-- -- p₁      : to₁ (inj₁ x) P≡ inj₂ dq₁
-- -- p₂      : from₂ dq₁ P≡ dr₁
-- -- p       : [ mkBij to₁ from₁ toFrom₁ fromTo₁ ∧ mkBij to₂ from₂ toFrom₂ fromTo₂ ⊨ inj₂ dr₁ ⇒ y ]

-- -- q₁      : from₁ (inj₁ y) P≡ inj₂ dq₂
-- -- q₂      : to₂ dq₂ P≡ dr₂
-- -- q       : [ mkBij from₁ to₁ fromTo₁ toFrom₁ ∧ mkBij from₂ to₂ fromTo₂ toFrom₂ ⊨ inj₂ dr₂ ⇒ z ]

-- -- dp₁     : .A ⊎ .B
-- -- dq₁     : .D
-- -- dr₁     : .B
-- -- ds₁     : .C

-- -- dp₂     : .C ⊎ .D
-- -- dq₂     : .B
-- -- dr₂     : .D
-- -- ds₂     : .A

-- -- to₁     : .A ⊎ .B → .C ⊎ .D
-- -- from₁   : .C ⊎ .D → .A ⊎ .B
-- -- toFrom₁ : (y₁ : .C ⊎ .D) → to₁ (from₁ y₁) P≡ y₁
-- -- fromTo₁ : (x₁ : .A ⊎ .B) → from₁ (to₁ x₁) P≡ x₁

-- -- to₂     : .B → .D
-- -- from₂   : .D → .B
-- -- toFrom₂ : (y₁ : .D) → to₂ (from₂ y₁) P≡ y₁
-- -- fromTo₂ : (x₁ : .B) → from₂ (to₂ x₁) P≡ x₁

-- -- x z : A

-- bijective b₁ b₂ x y z (step x₁ x₂ p) (done x₃) = {!!}
-- bijective b₁ b₂ x y z (done x₁) (step x₂ x₃ q₁) = {!!}
-- bijective (mkBij to₁ from₁ toFrom₁ fromTo₁)
--           (mkBij to₂ from₂ toFrom₂ fromTo₂)
--           x y z (done p) (done q) = inj₁-inj (
--             begin
--               inj₁ x
--             ≡⟨ Psym (fromTo₁ (inj₁ x)) ⟩
--               from₁ (to₁ (inj₁ x))
--             ≡⟨ Pcong from₁ p ⟩
--               from₁ (inj₁ y)
--             ≡⟨ q ⟩
--               inj₁ z
--             ∎
--           )

+-inj₂ : ∀ {A B C D} → A ℕ+ B P≡ C ℕ+ D → A P≡ C → B P≡ D
+-inj₂ {ℕzero} {B} {.0} {D} p Prefl = p
+-inj₂ {ℕsuc A} {B} {.(ℕsuc A)} {D} p Prefl = +-inj₂ {A} {B} {A} {D} (suc-inj p) Prefl

+-inj₁ : ∀ {A B C D} → A ℕ+ B P≡ C ℕ+ D → B P≡ D → A P≡ C
+-inj₁ {A} {B} {C} {D} p q = +-inj₂ {B} {A} {D} {C} (begin
    B ℕ+ A
  ≡⟨ NPS.+-comm B A ⟩
    A ℕ+ B
  ≡⟨ p ⟩
    C ℕ+ D
  ≡⟨ NPS.+-comm C D ⟩
    D ℕ+ C
  ∎) q

+-cancel : ∀ {A B C D} → A + B ≡ C + D → B ≡ D → A ≡ C
+-cancel {A} {B} {C} {D} p q = axiom (+-inj₁ (toEquality p) (toEquality q)) (mkBij to from toFrom fromTo)
  where
    to : lift A → lift C
    to x with run (toBijection p) (toBijection q) (inj₁ x)
    to x | y , prf = y

    from : lift C → lift A
    from x with run (Bsym (toBijection p)) (Bsym (toBijection q)) (inj₁ x)
    from x | y , prf = y

    toFrom : ∀ y → to (from y) P≡ y
    toFrom x with run (Bsym (toBijection p)) (Bsym (toBijection q)) (inj₁ x)
    toFrom x | y , prf with run (toBijection p) (toBijection q) (inj₁ y)
    toFrom x | y , prf | z , prf2 = bijective (toBijection p) (toBijection q) z (inj₁ y) x prf2 (fix (reverse (Bsym (toBijection p)) (Bsym (toBijection q)) x y prf))
      where
        symsym : ∀ {A B} → (t : A B≡ B) → Bsym (Bsym t) P≡ t
        symsym (mkBij to₁ from₁ x₁ x₂) = Prefl

        fix : [ Bsym (Bsym (toBijection p)) ∧ Bsym (Bsym (toBijection q)) ⊨ inj₁ y ⇒ x ] → [ toBijection p ∧ toBijection q ⊨ inj₁ y ⇒ x ]
        fix t rewrite symsym (toBijection p) | symsym (toBijection q) = t

    fromTo : ∀ x → from (to x) P≡ x
    fromTo x with run (toBijection p) (toBijection q) (inj₁ x)
    fromTo x | y , prf with run (Bsym (toBijection p)) (Bsym (toBijection q)) (inj₁ y)
    fromTo x | y , prf | z , prf2 = let test = reverse (toBijection p) (toBijection q) x y prf in bijective (Bsym (toBijection p)) (Bsym (toBijection q)) z (inj₁ y) x prf2 test
