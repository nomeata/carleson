import Carleson.Forest
import Carleson.HardyLittlewood
-- import Carleson.Proposition2
-- import Carleson.Proposition3

open MeasureTheory Measure NNReal Metric Complex Set Function BigOperators Bornology
open scoped ENNReal
open Classical -- We use quite some `Finset.filter`
noncomputable section


open scoped ShortVariables
variable {X : Type*} {a : ℕ} {q : ℝ} {K : X → X → ℂ} {σ₁ σ₂ : X → ℤ} {F G : Set X}
  [MetricSpace X] [ProofData a q K σ₁ σ₂ F G] [TileStructure Q D κ S o]

def aux𝓒 (k : ℕ) : Set (Grid X) :=
  {i : Grid X | ∃ j : Grid X, i ≤ j ∧ 2 ^ (- (k : ℤ)) * volume (j : Set X) < volume (G ∩ j) }

/-- The partition `𝓒(G, k)` of `Grid X` by volume, given in (5.1.1) and (5.1.2).
Note: the `G` is fixed with properties in `ProofData`. -/
def 𝓒 (k : ℕ) : Set (Grid X) :=
  aux𝓒 (k + 1) \ aux𝓒 k

/-- The definition `𝔓(k)` given in (5.1.3). -/
def TilesAt (k : ℕ) : Set (𝔓 X) := 𝓘 ⁻¹' 𝓒 k

def aux𝔐 (k n : ℕ) : Set (𝔓 X) :=
  {p ∈ TilesAt k | 2 ^ (- (n : ℤ)) * volume (𝓘 p : Set X) < volume (E₁ p) }

/-- The definition `𝔐(k, n)` given in (5.1.4) and (5.1.5). -/
def 𝔐 (k n : ℕ) : Set (𝔓 X) := maximals (·≤·) (aux𝔐 k n)

/-- The definition `dens'_k(𝔓')` given in (5.1.6). -/
def dens' (k : ℕ) (P' : Set (𝔓 X)) : ℝ≥0∞ :=
  ⨆ p' ∈ P', ⨆ (l : ℝ≥0), ⨆ (_hl : 2 ≤ l),
  ⨆ (p : 𝔓 X) (_h1p : p ∈ TilesAt k) (_h2p : smul l p' ≤ smul l p),
  l ^ (-a : ℤ) * volume (E₂ l p) / volume (𝓘 p : Set X)

lemma dens'_iSup {k : ℕ} {P : Set (𝔓 X)} : dens' k P = ⨆ p ∈ P, dens' k {p} := by
  simp_rw [dens', mem_singleton_iff, iSup_iSup_eq_left]

def auxℭ (k n : ℕ) : Set (𝔓 X) :=
  { p ∈ TilesAt k | 2 ^ (4 * a - n) < dens' k {p} }

/-- The partition `ℭ(k, n)` of `𝔓(k)` by density, given in (5.1.7). -/
def ℭ (k n : ℕ) : Set (𝔓 X) :=
  { p ∈ TilesAt k | dens' k {p} ∈ Ioc (2 ^ (4 * a - n)) (2 ^ (4 * a - n + 1)) }

lemma ℭ_subset_TilesAt {k n : ℕ} : ℭ k n ⊆ TilesAt (X := X) k := fun t mt ↦ by
  rw [ℭ, mem_setOf] at mt; exact mt.1

/-- The subset `𝔅(p)` of `𝔐(k, n)`, given in (5.1.8). -/
def 𝔅 (k n : ℕ) (p : 𝔓 X) : Set (𝔓 X) :=
  { m ∈ 𝔐 k n | smul 100 p ≤ smul 1 m }

def preℭ₁ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ k n | 2 ^ j ≤ (Finset.univ.filter (· ∈ 𝔅 k n p)).card }

/-- The subset `ℭ₁(k, n, j)` of `ℭ(k, n)`, given in (5.1.9).
Together with `𝔏₀(k, n)` this forms a partition. -/
def ℭ₁ (k n j : ℕ) : Set (𝔓 X) :=
  preℭ₁ k n j \ preℭ₁ k n (j + 1)

lemma ℭ₁_subset_ℭ {k n j : ℕ} : ℭ₁ k n j ⊆ ℭ (X := X) k n := fun t mt ↦ by
  rw [ℭ₁, preℭ₁, mem_diff, mem_setOf] at mt; exact mt.1.1

lemma card_𝔅_of_mem_ℭ₁ {k n j : ℕ} {p : 𝔓 X} (hp : p ∈ ℭ₁ k n j) :
    (𝔅 k n p).toFinset.card ∈ Ico (2 ^ j) (2 ^ (j + 1)) := by
  simp_rw [ℭ₁, mem_diff, preℭ₁, mem_setOf, hp.1.1, true_and, not_le] at hp
  constructor
  · convert hp.1; ext; simp
  · convert hp.2; ext; simp

/-- The subset `𝔏₀(k, n)` of `ℭ(k, n)`, given in (5.1.10).
Not to be confused with `𝔏₀(k, n, j)` which is called `𝔏₀'` in Lean. -/
def 𝔏₀ (k n : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ k n | 𝔅 k n p = ∅ }

/-- `𝔏₁(k, n, j, l)` consists of the minimal elements in `ℭ₁(k, n, j)` not in
  `𝔏₁(k, n, j, l')` for some `l' < l`. Defined near (5.1.11). -/
def 𝔏₁ (k n j l : ℕ) : Set (𝔓 X) :=
  minimals (·≤·) (ℭ₁ k n j \ ⋃ (l' < l), 𝔏₁ k n j l')

lemma 𝔏₁_disjoint {k n j l l' : ℕ} (h : l ≠ l') : Disjoint (𝔏₁ (X := X) k n j l) (𝔏₁ k n j l') := by
  wlog hl : l < l'; · exact (this h.symm (by omega)).symm
  rw [disjoint_right]; intro p hp
  rw [𝔏₁, mem_minimals_iff, mem_diff] at hp; replace hp := hp.1.2; contrapose! hp
  refine mem_iUnion₂_of_mem hl hp

lemma exists_le_of_mem_𝔏₁ {k n j l : ℕ} {p : 𝔓 X} (hp : p ∈ 𝔏₁ k n j l) :
    ∃ p' ∈ ℭ₁ k n j, p' ≤ p ∧ 𝔰 p' + l ≤ 𝔰 p := by
  induction l generalizing p with
  | zero =>
    rw [𝔏₁] at hp; simp_rw [not_lt_zero', iUnion_of_empty, iUnion_empty, diff_empty] at hp
    use p, hp.1; simp
  | succ l ih =>
    have np : p ∉ 𝔏₁ k n j l := disjoint_right.mp (𝔏₁_disjoint (by omega)) hp
    rw [𝔏₁, mem_minimals_iff] at hp np
    have rl : p ∈ ℭ₁ k n j \ ⋃ (l' < l), 𝔏₁ k n j l' := by
      refine mem_of_mem_of_subset hp.1 (diff_subset_diff_right ?_)
      refine biUnion_subset_biUnion_left fun k hk ↦ ?_
      rw [mem_def, Nat.le_eq] at hk ⊢; omega
    simp_rw [rl, true_and] at np; push_neg at np; obtain ⟨p', hp', lp⟩ := np
    have mp' : p' ∈ 𝔏₁ k n j l := by
      by_contra h
      have cp : p' ∈ ℭ₁ k n j \ ⋃ (l' < l + 1), 𝔏₁ k n j l' := by
        have : ∀ l', l' < l + 1 ↔ l' < l ∨ l' = l := by omega
        simp_rw [this, iUnion_or, iUnion_union_distrib]
        simp only [iUnion_iUnion_eq_left, mem_diff, mem_union, mem_iUnion, exists_prop, not_or,
          not_exists, not_and] at hp' ⊢
        tauto
      exact absurd (hp.2 cp lp.1) (ne_eq _ _ ▸ lp.2)
    obtain ⟨d, md, ld, sd⟩ := ih mp'; use d, md, (ld.trans lp.1)
    rw [Nat.cast_add, Nat.cast_one, ← add_assoc]
    have 𝓘lt : 𝓘 p' < 𝓘 p := by
      refine lt_of_le_of_ne lp.1.1 (not_lt_of_𝓘_eq_𝓘.mt ?_)
      rw [not_not]; exact lt_of_le_of_ne lp.1 lp.2.symm
    have 𝔰lt : 𝔰 p' < 𝔰 p := by rw [Grid.lt_def] at 𝓘lt; exact 𝓘lt.2
    omega

/-- The subset `ℭ₂(k, n, j)` of `ℭ₁(k, n, j)`, given in (5.1.13). -/
def ℭ₂ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₁ k n j \ ⋃ (l ≤ Z * (n + 1)), 𝔏₁ k n j l

lemma ℭ₂_subset_ℭ₁ {k n j : ℕ} : ℭ₂ k n j ⊆ ℭ₁ (X := X) k n j := fun t mt ↦ by
  rw [ℭ₂, mem_diff] at mt; exact mt.1

lemma exists_le_of_mem_ℭ₂ {k n j : ℕ} {p : 𝔓 X} (hp : p ∈ ℭ₂ k n j) :
    ∃ p' ∈ ℭ₁ k n j, p' ≤ p ∧ 𝔰 p' + (Z * (n + 1) : ℕ) ≤ 𝔰 p := by
  have mp : p ∈ ℭ₁ k n j \ ⋃ (l' < Z * (n + 1)), 𝔏₁ k n j l' := by
    refine mem_of_mem_of_subset hp (diff_subset_diff_right ?_)
    refine biUnion_subset_biUnion_left fun k hk ↦ ?_
    rw [mem_def, Nat.le_eq] at hk ⊢; omega
  let C : Finset (𝔓 X) :=
    ((ℭ₁ k n j).toFinset \ (Finset.range (Z * (n + 1))).biUnion fun l' ↦
      (𝔏₁ k n j l').toFinset).filter (· ≤ p)
  have Cn : C.Nonempty := by
    use p
    simp_rw [C, Finset.mem_filter, le_rfl, and_true, Finset.mem_sdiff,
      Finset.mem_biUnion, Finset.mem_range, not_exists, not_and, mem_toFinset]
    simp_rw [mem_diff, mem_iUnion, exists_prop, not_exists, not_and] at mp
    exact mp
  obtain ⟨p', mp', maxp'⟩ := C.exists_minimal Cn
  simp_rw [C, Finset.mem_filter, Finset.mem_sdiff, Finset.mem_biUnion, Finset.mem_range, not_exists,
    not_and, mem_toFinset] at mp' maxp'
  conv at maxp' => enter [x]; rw [and_imp]
  have mp'₁ : p' ∈ 𝔏₁ k n j (Z * (n + 1)) := by
    rw [𝔏₁, mem_minimals_iff]
    simp_rw [mem_diff, mem_iUnion, exists_prop, not_exists, not_and]
    exact ⟨mp'.1, fun y hy ly ↦ (eq_of_le_of_not_lt ly (maxp' y hy (ly.trans mp'.2))).symm⟩
  obtain ⟨po, mpo, lpo, spo⟩ := exists_le_of_mem_𝔏₁ mp'₁
  use po, mpo, lpo.trans mp'.2, spo.trans mp'.2.1.2

/-- The subset `𝔘₁(k, n, j)` of `ℭ₁(k, n, j)`, given in (5.1.14). -/
def 𝔘₁ (k n j : ℕ) : Set (𝔓 X) :=
  { u ∈ ℭ₁ k n j | ∀ p ∈ ℭ₁ k n j, 𝓘 u < 𝓘 p → Disjoint (ball_(u) (𝒬 u) 100) (ball_(p) (𝒬 p) 100) }

lemma 𝔘₁_subset_ℭ₁ {k n j : ℕ} : 𝔘₁ k n j ⊆ ℭ₁ (X := X) k n j := fun _ mu ↦ mu.1

/-- The subset `𝔏₂(k, n, j)` of `ℭ₂(k, n, j)`, given in (5.1.15). -/
def 𝔏₂ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ₂ k n j | ¬ ∃ u ∈ 𝔘₁ k n j, 𝓘 p ≠ 𝓘 u ∧ smul 2 p ≤ smul 1 u }

/-- The subset `ℭ₃(k, n, j)` of `ℭ₂(k, n, j)`, given in (5.1.16). -/
def ℭ₃ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₂ k n j \ 𝔏₂ k n j

lemma ℭ₃_subset_ℭ₂ {k n j : ℕ} : ℭ₃ k n j ⊆ ℭ₂ (X := X) k n j := fun t mt ↦ by
  rw [ℭ₃, mem_diff] at mt; exact mt.1

/-- `𝔏₃(k, n, j, l)` consists of the maximal elements in `ℭ₃(k, n, j)` not in
  `𝔏₃(k, n, j, l')` for some `l' < l`. Defined near (5.1.17). -/
def 𝔏₃ (k n j l : ℕ) : Set (𝔓 X) :=
  maximals (·≤·) (ℭ₃ k n j \ ⋃ (l' < l), 𝔏₃ k n j l')

/-- The subset `ℭ₄(k, n, j)` of `ℭ₃(k, n, j)`, given in (5.1.19). -/
def ℭ₄ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₃ k n j \ ⋃ (l ≤ Z * (n + 1)), 𝔏₃ k n j l

lemma ℭ₄_subset_ℭ₃ {k n j : ℕ} : ℭ₄ k n j ⊆ ℭ₃ (X := X) k n j := fun t mt ↦ by
  rw [ℭ₄, mem_diff] at mt; exact mt.1

/-- The subset `𝓛(u)` of `Grid X`, given near (5.1.20).
Note: It seems to also depend on `n`. -/
def 𝓛 (n : ℕ) (u : 𝔓 X) : Set (Grid X) :=
  { i : Grid X | i ≤ 𝓘 u ∧ s i + Z * (n + 1) + 1 = 𝔰 u ∧ ¬ ball (c i) (8 * D ^ s i) ⊆ 𝓘 u }

/-- The subset `𝔏₄(k, n, j)` of `ℭ₄(k, n, j)`, given near (5.1.22).
Todo: we may need to change the definition to say that `p`
is at most the least upper bound of `𝓛 n u` in `Grid X`. -/
def 𝔏₄ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ₄ k n j | ∃ u ∈ 𝔘₁ k n j, (𝓘 p : Set X) ⊆ ⋃ (i ∈ 𝓛 (X := X) n u), i }

/-- The subset `ℭ₅(k, n, j)` of `ℭ₄(k, n, j)`, given in (5.1.23). -/
def ℭ₅ (k n j : ℕ) : Set (𝔓 X) :=
  ℭ₄ k n j \ 𝔏₄ k n j

lemma ℭ₅_subset_ℭ₄ {k n j : ℕ} : ℭ₅ k n j ⊆ ℭ₄ (X := X) k n j := fun t mt ↦ by
  rw [ℭ₅, mem_diff] at mt; exact mt.1

/-- The set $\mathcal{P}_{F,G}$, defined in (5.1.24). -/
def highDensityTiles : Set (𝔓 X) :=
  { p : 𝔓 X | 2 ^ (2 * a + 5) * volume F / volume G < dens₂ {p} }

lemma highDensityTiles_empty (hF : volume F = 0) : highDensityTiles = (∅ : Set (𝔓 X)) := by
  suffices ∀ (p : 𝔓 X), dens₂ {p} = 0 by simp [highDensityTiles, this]
  simp_rw [dens₂, ENNReal.iSup_eq_zero, ENNReal.div_eq_zero_iff]
  exact fun _ _ _ r _ ↦ Or.inl <| measure_inter_null_of_null_left (ball (𝔠 _) r) hF

lemma highDensityTiles_empty' (hG : volume G = 0) :
    highDensityTiles = (∅ : Set (𝔓 X)) := by
  by_cases hF : volume F = 0
  · exact highDensityTiles_empty hF
  suffices 2 ^ (2 * a + 5) * volume F / volume G = ⊤ by simp [highDensityTiles, this]
  exact hG ▸ ENNReal.div_zero (mul_ne_zero (by simp) hF)

/-- The exceptional set `G₁`, defined in (5.1.25). -/
def G₁ : Set X := ⋃ (p : 𝔓 X) (_ : p ∈ highDensityTiles), 𝓘 p

lemma G₁_empty (hF : volume F = 0) : G₁ = (∅ : Set X) := by
  simp [G₁, highDensityTiles_empty hF]

lemma G₁_empty' (hG : volume G = 0) : G₁ = (∅ : Set X) := by
  simp [G₁, highDensityTiles_empty' hG]

/-- The set `A(λ, k, n)`, defined in (5.1.26). -/
def setA (l k n : ℕ) : Set X :=
  {x : X | l * 2 ^ (n + 1) < stackSize (𝔐 (X := X) k n) x }

lemma setA_subset_iUnion_𝓒 {l k n : ℕ} :
    setA (X := X) l k n ⊆ ⋃ i ∈ 𝓒 (X := X) k, ↑i := fun x mx ↦ by
  simp_rw [setA, mem_setOf, stackSize, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id,
    Finset.filter_filter] at mx
  replace mx := (zero_le _).trans_lt mx
  rw [Finset.card_pos] at mx
  obtain ⟨p, hp⟩ := mx
  simp_rw [Finset.mem_filter, Finset.mem_univ, true_and, 𝔐] at hp
  rw [mem_iUnion₂]; use 𝓘 p, ?_, hp.2
  have hp' : p ∈ aux𝔐 k n := mem_of_mem_of_subset hp.1 (maximals_subset ..)
  rw [aux𝔐, mem_setOf, TilesAt, mem_preimage] at hp'
  exact hp'.1

lemma setA_subset_setA {l k n : ℕ} : setA (X := X) (l + 1) k n ⊆ setA l k n := by
  refine setOf_subset_setOf.mpr fun x hx ↦ ?_
  calc
    _ ≤ _ := by gcongr; omega
    _ < _ := hx

lemma measurable_setA {l k n : ℕ} : MeasurableSet (setA (X := X) l k n) :=
  measurableSet_lt measurable_const (Finset.measurable_sum _ fun _ _ ↦ measurable_one.indicator coeGrid_measurable)

/-- Finset of cubes in `setA`. Appears in the proof of Lemma 5.2.5. -/
def MsetA (l k n : ℕ) : Finset (Grid X) := Finset.univ.filter fun j ↦ (j : Set X) ⊆ setA l k n

/-- The set `G₂`, defined in (5.1.27). -/
def G₂ : Set X := ⋃ (n : ℕ) (k < n), setA (2 * n + 6) k n

/-- The set `G₃`, defined in (5.1.28). -/
def G₃ : Set X := ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3) (p ∈ 𝔏₄ (X := X) k n j), 𝓘 p

/-- The set `G'`, defined below (5.1.28). -/
def G' : Set X := G₁ ∪ G₂ ∪ G₃

/-- The set `𝔓₁`, defined in (5.1.30). -/
def 𝔓₁ : Set (𝔓 X) := ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3), ℭ₅ k n j

variable {k n j l : ℕ} {p p' u u' : 𝔓 X} {x : X}

/-! ## Section 5.2 and Lemma 5.1.1 -/

section first_exception

open ENNReal

/-- Lemma 5.2.1 -/
lemma first_exception' : volume (G₁ : Set X) ≤ 2 ^ (- 5 : ℤ) * volume G := by
  -- Handle trivial cases
  by_cases hF : volume F = 0
  · simp [G₁_empty hF]
  by_cases hG : volume G = 0
  · exact (G₁_empty' hG ▸ OuterMeasureClass.measure_empty volume) ▸ zero_le _
  -- Define constant `K` and prove 0 < K < ⊤
  let K := 2 ^ (2 * a + 5) * volume F / volume G
  have vol_G_ne_top : volume G ≠ ⊤ :=
    lt_of_le_of_lt (measure_mono (ProofData.G_subset)) measure_ball_lt_top |>.ne
  have K0 : K > 0 := by
    refine ENNReal.div_pos (ne_of_gt ?_) vol_G_ne_top
    exact mul_pos_iff.2 ⟨ENNReal.pow_pos two_pos _, measure_pos_of_superset subset_rfl hF⟩
  have K_ne_top : K ≠ ⊤ := by
    simp only [K]
    refine ne_of_lt (div_lt_top (ne_of_lt (mul_lt_top (pow_ne_top two_ne_top) ?_)) hG)
    exact lt_of_le_of_lt (measure_mono (ProofData.F_subset)) measure_ball_lt_top |>.ne
  -- Define function `r : 𝔓 X → ℝ`, with garbage value `0` for `p ∉ highDensityTiles`
  have : ∀ p ∈ highDensityTiles, ∃ r ≥ 4 * (D : ℝ) ^ 𝔰 p,
      volume (F ∩ (ball (𝔠 p) r)) ≥ K * volume (ball (𝔠 p) r) := by
    intro p hp
    simp_rw [highDensityTiles, mem_setOf_eq, dens₂, lt_iSup_iff, mem_singleton_iff] at hp
    rcases hp with ⟨p, rfl, r, hr, h⟩
    use r, hr
    refine ENNReal.lt_div_iff_mul_lt ?_ (Or.inl (measure_ball_ne_top (𝔠 p) r)) |>.mp h |>.le
    have r0 : r > 0 := lt_of_lt_of_le (by have := defaultD_pos a; positivity) hr
    exact Or.inl <| (measure_ball_pos volume (𝔠 p) r0).ne.symm
  let r (p : 𝔓 X) := dite (p ∈ highDensityTiles) (fun hp ↦ choose (this p hp)) (fun _ ↦ 0)
  have hr {p : 𝔓 X} (hp : p ∈ highDensityTiles) := choose_spec (this p hp)
  -- Define a collection of balls `𝓑` that covers `G₁`. Then we need only bound the volume of ⋃ 𝓑
  let 𝓑 : Finset (X × ℝ) := Finset.image (fun p ↦ (𝔠 p, r p)) highDensityTiles.toFinset
  have : (G₁ : Set X) ⊆ ⋃ z ∈ 𝓑, (ball z.1 z.2) := by
    refine fun x hx ↦ mem_iUnion.2 ?_
    simp only [G₁, mem_iUnion, exists_prop] at hx
    rcases hx with ⟨p, hp, xp⟩
    use (𝔠 p, r p)
    simp only [mem_iUnion, mem_ball, exists_prop, Finset.mem_image, mem_toFinset, 𝓑]
    refine ⟨by {use p}, ?_⟩
    suffices GridStructure.coeGrid (𝓘 p) ⊆ ball (𝔠 p) (r p) from this xp
    apply Grid_subset_ball.trans ∘ ball_subset_ball
    convert (hr hp).1.le
    simp [r, hp]
  apply (OuterMeasureClass.measure_mono volume this).trans
  -- Apply `measure_biUnion_le_lintegral` to `u := F.indicator 1` to bound the volume of ⋃ 𝓑.
  let u := F.indicator (1 : X → ℝ≥0∞)
  have hu : AEStronglyMeasurable u volume :=
    AEStronglyMeasurable.indicator aestronglyMeasurable_one measurableSet_F
  have h2u : ∀ z ∈ 𝓑, K * volume (Metric.ball z.1 z.2) ≤ ∫⁻ (x : X) in ball z.1 z.2, u x := by
    intro z hz
    simp only [Finset.mem_image, mem_toFinset, 𝓑] at hz
    rcases hz with ⟨p, h, rfl⟩
    simpa [u, lintegral_indicator, Measure.restrict_apply, measurableSet_F, r, h] using (hr h).2.le
  have ineq := measure_biUnion_le_lintegral' (A := defaultA a) 𝓑 K0 hu h2u
  simp only [u, lintegral_indicator, measurableSet_F, Pi.one_apply, lintegral_const,
    MeasurableSet.univ, Measure.restrict_apply, univ_inter, one_mul] at ineq
  rw [← mul_le_mul_left K0.ne.symm K_ne_top]
  apply le_of_le_of_eq ineq
  -- Prove that the desired bound for the volume of ⋃ 𝓑 is equal to the bound proven above.
  simp_rw [defaultA, Nat.cast_pow, Nat.cast_ofNat, ENNReal.coe_pow, coe_ofNat, K]
  have : (volume G)⁻¹ * (2 ^ (2 * a + 5) * volume F) * (2 ^ (-5 : ℤ) * volume G) =
      (2 ^ (2 * a + 5) * 2 ^ (-5 : ℤ)) * volume F * ((volume G)⁻¹ * volume G) := by ring
  rw [ENNReal.div_eq_inv_mul, ← mul_one (_ * _), this]
  congr
  · have h : (2 : ℝ≥0∞) ^ (2 * a + 5) = (2 : ℝ≥0∞) ^ (2 * a + 5 : ℤ) := by norm_cast
    rw [h, ← ENNReal.zpow_add (NeZero.ne 2) two_ne_top, add_neg_cancel_right, ← pow_mul, mul_comm 2]
    norm_cast
  · exact ENNReal.inv_mul_cancel hG vol_G_ne_top |>.symm

lemma first_exception : volume (G₁ : Set X) ≤ 2 ^ (- 4 : ℤ) * volume G := by
  calc volume G₁ ≤ 2 ^ (-5 : ℤ) * volume G := first_exception'
    _ ≤ 2 ^ (-4 : ℤ) * volume G := by gcongr <;> norm_num

  end first_exception

/-- Lemma 5.2.2 -/
lemma dense_cover (k : ℕ) : volume (⋃ i ∈ 𝓒 (X := X) k, (i : Set X)) ≤ 2 ^ (k + 1) * volume G := by
  let M : Finset (Grid X) :=
    Finset.univ.filter fun j ↦ (2 ^ (-(k + 1 : ℕ) : ℤ) * volume (j : Set X) < volume (G ∩ j))
  have s₁ : ⋃ i ∈ 𝓒 (X := X) k, (i : Set X) ⊆ ⋃ i ∈ M, ↑i := by
    simp_rw [𝓒]; intro q mq; rw [mem_iUnion₂] at mq ⊢; obtain ⟨i, hi, mi⟩ := mq
    rw [aux𝓒, mem_diff, mem_setOf] at hi; obtain ⟨j, hj, mj⟩ := hi.1
    use j, ?_, mem_of_mem_of_subset mi hj.1
    simpa [M] using mj
  let M' := Grid.maxCubes M
  have s₂ : ⋃ i ∈ M, (i : Set X) ⊆ ⋃ i ∈ M', ↑i := iUnion₂_mono' fun i mi ↦ by
    obtain ⟨j, mj, hj⟩ := Grid.exists_maximal_supercube mi; use j, mj, hj.1
  calc
    _ ≤ volume (⋃ i ∈ M', (i : Set X)) := measure_mono (s₁.trans s₂)
    _ ≤ ∑ i ∈ M', volume (i : Set X) := measure_biUnion_finset_le M' _
    _ ≤ 2 ^ (k + 1) * ∑ j ∈ M', volume (G ∩ j) := by
      rw [Finset.mul_sum]; refine Finset.sum_le_sum fun i hi ↦ ?_
      replace hi : i ∈ M := Finset.mem_of_subset (Finset.filter_subset _ M) hi
      simp_rw [M, Finset.mem_filter, Finset.mem_univ, true_and] at hi
      rw [← ENNReal.rpow_intCast, show (-(k + 1 : ℕ) : ℤ) = (-(k + 1) : ℝ) by simp,
        mul_comm, ← ENNReal.lt_div_iff_mul_lt (by simp) (by simp), ENNReal.div_eq_inv_mul,
        ← ENNReal.rpow_neg, neg_neg] at hi
      exact_mod_cast hi.le
    _ = 2 ^ (k + 1) * volume (⋃ j ∈ M', G ∩ j) := by
      congr; refine (measure_biUnion_finset (fun _ mi _ mj hn ↦ ?_) (fun _ _ ↦ ?_)).symm
      · exact ((Grid.maxCubes_pairwiseDisjoint mi mj hn).inter_right' G).inter_left' G
      · exact measurableSet_G.inter coeGrid_measurable
    _ ≤ _ := mul_le_mul_left' (measure_mono (iUnion₂_subset fun _ _ ↦ inter_subset_left)) _

/-- Lemma 5.2.3 -/
lemma pairwiseDisjoint_E1 : (𝔐 (X := X) k n).PairwiseDisjoint E₁ := fun p mp p' mp' h ↦ by
  change Disjoint _ _
  contrapose! h
  have h𝓘 := (Disjoint.mono (E₁_subset p) (E₁_subset p')).mt h
  wlog hs : s (𝓘 p') ≤ s (𝓘 p) generalizing p p'
  · rw [disjoint_comm] at h h𝓘; rw [not_le] at hs; rw [this p' mp' p mp h h𝓘 hs.le]
  obtain ⟨x, ⟨-, mxp⟩, ⟨-, mxp'⟩⟩ := not_disjoint_iff.mp h
  rw [mem_preimage] at mxp mxp'
  have l𝓘 := Grid.le_def.mpr ⟨(fundamental_dyadic hs).resolve_right (disjoint_comm.not.mpr h𝓘), hs⟩
  have sΩ := (relative_fundamental_dyadic l𝓘).resolve_left <| not_disjoint_iff.mpr ⟨_, mxp', mxp⟩
  exact (eq_of_mem_maximals mp' (mem_of_mem_of_subset mp (maximals_subset ..)) ⟨l𝓘, sΩ⟩).symm

/-- Lemma 5.2.4 -/
lemma dyadic_union (hx : x ∈ setA l k n) : ∃ i : Grid X, x ∈ i ∧ (i : Set X) ⊆ setA l k n := by
  let M : Finset (𝔓 X) := Finset.univ.filter (fun p ↦ p ∈ 𝔐 k n ∧ x ∈ 𝓘 p)
  simp_rw [setA, mem_setOf, stackSize, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id,
    Finset.filter_filter] at hx ⊢
  obtain ⟨b, memb, minb⟩ := M.exists_min_image 𝔰 (Finset.card_pos.mp (zero_le'.trans_lt hx))
  simp_rw [M, Finset.mem_filter, Finset.mem_univ, true_and] at memb minb
  use 𝓘 b, memb.2; intro c mc; rw [mem_setOf]
  refine hx.trans_le (Finset.card_le_card fun y hy ↦ ?_)
  simp_rw [Finset.mem_filter, Finset.mem_univ, true_and] at hy ⊢
  exact ⟨hy.1, mem_of_mem_of_subset mc (Grid.le_of_mem_of_mem (minb y hy) memb.2 hy.2).1⟩

lemma iUnion_MsetA_eq_setA : ⋃ i ∈ MsetA (X := X) l k n, ↑i = setA (X := X) l k n := by
  ext x
  simp_rw [mem_iUnion₂, MsetA, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor <;> intro mx
  · obtain ⟨j, mj, lj⟩ := mx; exact mem_of_mem_of_subset lj mj
  · obtain ⟨j, mj, lj⟩ := dyadic_union mx; use j, lj, mj

/-- Equation (5.2.7) in the proof of Lemma 5.2.5. -/
lemma john_nirenberg_aux1 {L : Grid X} (mL : L ∈ Grid.maxCubes (MsetA l k n))
    (mx : x ∈ setA (l + 1) k n) (mx₂ : x ∈ L) : 2 ^ (n + 1) ≤
    stackSize { q ∈ 𝔐 (X := X) k n | 𝓘 q ≤ L} x := by
  -- LHS of equation (5.2.6) is strictly greater than `(l + 1) * 2 ^ (n + 1)`
  rw [setA, mem_setOf, ← stackSize_setOf_add_stackSize_setOf_not (P := fun p' ↦ 𝓘 p' ≤ L)] at mx
  -- Rewrite second sum of RHS of (5.2.6) so that it sums over tiles `q` satisfying `L < 𝓘 q`
  nth_rw 2 [← stackSize_setOf_add_stackSize_setOf_not (P := fun p' ↦ Disjoint (𝓘 p' : Set X) L)]
    at mx
  simp_rw [mem_setOf_eq, and_assoc] at mx
  have mid0 : stackSize { p' ∈ 𝔐 k n | ¬𝓘 p' ≤ L ∧ Disjoint (𝓘 p' : Set X) L} x = 0 := by
    simp_rw [stackSize, Finset.sum_eq_zero_iff, indicator_apply_eq_zero, imp_false,
      Finset.mem_filter, Finset.mem_univ, true_and]
    rintro y ⟨-, -, dj2⟩
    exact disjoint_right.mp dj2 mx₂
  rw [mid0, zero_add] at mx
  have req :
      { p' | p' ∈ 𝔐 k n ∧ ¬𝓘 p' ≤ L ∧ ¬Disjoint (𝓘 p' : Set X) L } =
      { p' | p' ∈ 𝔐 k n ∧ L < 𝓘 p' } := by
    ext q
    simp_rw [mem_setOf_eq, and_congr_right_iff]
    refine fun _ ↦ ⟨fun h ↦ ?_, ?_⟩
    · apply lt_of_le_of_ne <| (le_or_ge_or_disjoint.resolve_left h.1).resolve_right h.2
      by_contra k; subst k; simp at h
    · rw [Grid.lt_def, Grid.le_def, not_and_or, not_le]
      exact fun h ↦ ⟨Or.inr h.2, not_disjoint_iff.mpr ⟨x, mem_of_mem_of_subset mx₂ h.1, mx₂⟩⟩
  rw [req] at mx
  -- The new second sum of RHS is at most `l * 2 ^ (n + 1)`
  set Q₁ := { q ∈ 𝔐 (X := X) k n | 𝓘 q ≤ L }
  set Q₂ := { q ∈ 𝔐 (X := X) k n | L < 𝓘 q }
  have Ql : stackSize Q₂ x ≤ l * 2 ^ (n + 1) := by
    by_cases h : IsMax L
    · rw [Grid.isMax_iff] at h
      have : Q₂ = ∅ := by
        ext y; simp_rw [Q₂, mem_setOf_eq, Set.not_mem_empty, iff_false, not_and, h, Grid.lt_def,
          not_and_or, not_lt]
        exact fun _ ↦ Or.inr (Grid.le_topCube).2
      simp [stackSize, this]
    have Lslq : ∀ q ∈ Q₂, L.succ ≤ 𝓘 q := fun q mq ↦ Grid.succ_le_of_lt mq.2
    have Lout : ¬(L.succ : Set X) ⊆ setA (X := X) l k n := by
      by_contra! hs
      rw [Grid.maxCubes, Finset.mem_filter] at mL
      apply absurd _ h
      exact Grid.max_of_le_succ
        (mL.2 L.succ (Finset.mem_filter.mpr ⟨Finset.mem_univ _, hs⟩) Grid.le_succ).symm.le
    rw [not_subset_iff_exists_mem_not_mem] at Lout
    obtain ⟨x', mx', nx'⟩ := Lout
    calc
      _ = stackSize Q₂ x' := by
        refine stackSize_congr fun q mq ↦ ?_
        simp_rw [mem_of_mem_of_subset mx₂ (Grid.le_succ.trans (Lslq q mq)).1,
          mem_of_mem_of_subset mx' (Lslq q mq).1]
      _ ≤ stackSize (𝔐 (X := X) k n) x' := by
        refine stackSize_mono <| sep_subset ..
      _ ≤ l * 2 ^ (n + 1) := by rwa [setA, mem_setOf_eq, not_lt] at nx'
  -- so the (unchanged) first sum of RHS is at least `2 ^ (n + 1)`
  rw [add_one_mul] at mx; omega

/-- Equation (5.2.11) in the proof of Lemma 5.2.5. -/
lemma john_nirenberg_aux2 {L : Grid X} (mL : L ∈ Grid.maxCubes (MsetA l k n)) :
    2 * volume (setA (X := X) (l + 1) k n ∩ L) ≤ volume (L : Set X) := by
  let Q₁ := Finset.univ.filter (fun q ↦ q ∈ 𝔐 (X := X) k n ∧ 𝓘 q ≤ L)
  have Q₁m : ∀ i ∈ Q₁, Measurable ((𝓘 i : Set X).indicator (1 : X → ℝ≥0∞)) := fun _ _ ↦
    measurable_one.indicator coeGrid_measurable
  have e528 : ∑ q ∈ Q₁, volume (E₁ q) ≤ volume (L : Set X) :=
    calc
      _ = volume (⋃ q ∈ Q₁, E₁ q) := by
        refine (measure_biUnion_finset (fun p mp q mq hn ↦ ?_) (fun _ _ ↦ ?_)).symm
        · simp_rw [Finset.mem_coe, Q₁, Finset.mem_filter] at mp mq
          exact pairwiseDisjoint_E1 mp.2.1 mq.2.1 hn
        · exact (coeGrid_measurable.inter measurableSet_G).inter
            (SimpleFunc.measurableSet_preimage ..)
      _ ≤ volume (⋃ q ∈ Q₁, (𝓘 q : Set X)) := measure_mono (iUnion₂_mono fun q _ ↦ E₁_subset q)
      _ ≤ _ := by
        apply measure_mono (iUnion₂_subset fun q mq ↦ ?_)
        simp_rw [Q₁, Finset.mem_filter] at mq; exact mq.2.2.1
  have e529 : ∑ q ∈ Q₁, volume (𝓘 q : Set X) ≤ 2 ^ n * volume (L : Set X) :=
    calc
      _ ≤ ∑ q ∈ Q₁, 2 ^ n * volume (E₁ q) := by
        refine Finset.sum_le_sum fun q mq ↦ ?_
        simp_rw [Q₁, Finset.mem_filter, 𝔐, maximals, aux𝔐, mem_setOf] at mq
        replace mq := mq.2.1.1.2
        rw [← ENNReal.rpow_intCast, show (-(n : ℕ) : ℤ) = (-n : ℝ) by simp, mul_comm,
          ← ENNReal.lt_div_iff_mul_lt (by simp) (by simp), ENNReal.div_eq_inv_mul,
          ← ENNReal.rpow_neg, neg_neg] at mq
        exact_mod_cast mq.le
      _ ≤ _ := by rw [← Finset.mul_sum]; exact mul_le_mul_left' e528 _
  rw [← ENNReal.mul_le_mul_left (a := 2 ^ n) (by simp) (by simp), ← mul_assoc, ← pow_succ]
  calc
    _ = ∫⁻ x in setA (X := X) (l + 1) k n ∩ L, 2 ^ (n + 1) := (setLIntegral_const _ _).symm
    _ ≤ ∫⁻ x in setA (X := X) (l + 1) k n ∩ L, ∑ q ∈ Q₁, (𝓘 q : Set X).indicator 1 x := by
      refine setLIntegral_mono (by simp) (Finset.measurable_sum Q₁ Q₁m) fun x ⟨mx, mx₂⟩ ↦ ?_
      have : 2 ^ (n + 1) ≤ ∑ q ∈ Q₁, (𝓘 q : Set X).indicator 1 x := by
        convert john_nirenberg_aux1 mL mx mx₂
        simp_rw [stackSize, Q₁, mem_setOf_eq]
        congr
      have lcast : (2 : ℝ≥0∞) ^ (n + 1) = ((2 ^ (n + 1) : ℕ) : ℝ).toNNReal := by
        rw [toNNReal_coe_nat, ENNReal.coe_natCast]; norm_cast
      have rcast : ∑ q ∈ Q₁, (𝓘 q : Set X).indicator (1 : X → ℝ≥0∞) x =
          (((∑ q ∈ Q₁, (𝓘 q : Set X).indicator (1 : X → ℕ) x) : ℕ) : ℝ).toNNReal := by
        rw [toNNReal_coe_nat, ENNReal.coe_natCast, Nat.cast_sum]; congr!; simp [indicator]
      rw [lcast, rcast, ENNReal.coe_le_coe]
      exact Real.toNNReal_le_toNNReal (Nat.cast_le.mpr this)
    _ ≤ ∫⁻ x, ∑ q ∈ Q₁, (𝓘 q : Set X).indicator 1 x := setLIntegral_le_lintegral _ _
    _ = ∑ q ∈ Q₁, ∫⁻ x, (𝓘 q : Set X).indicator 1 x := lintegral_finset_sum _ Q₁m
    _ = ∑ q ∈ Q₁, volume (𝓘 q : Set X) := by
      congr!; exact lintegral_indicator_one coeGrid_measurable
    _ ≤ _ := e529

/-- Lemma 5.2.5 -/
lemma john_nirenberg : volume (setA (X := X) l k n) ≤ 2 ^ (k + 1 - l : ℤ) * volume G := by
  induction l with
  | zero =>
    calc
      _ ≤ volume (⋃ i ∈ 𝓒 (X := X) k, (i : Set X)) := measure_mono setA_subset_iUnion_𝓒
      _ ≤ _ := by
        rw [← ENNReal.rpow_intCast, show (k + 1 - (0 : ℕ) : ℤ) = (k + 1 : ℝ) by simp]
        exact_mod_cast dense_cover k
  | succ l ih =>
    suffices 2 * volume (setA (X := X) (l + 1) k n) ≤ volume (setA (X := X) l k n) by
      rw [← ENNReal.mul_le_mul_left (a := 2) (by simp) (by simp), ← mul_assoc]; apply this.trans
      convert ih using 2; nth_rw 1 [← zpow_one 2, ← ENNReal.zpow_add (by simp) (by simp)]
      congr 1; omega
    calc
      _ = 2 * ∑ L ∈ Grid.maxCubes (MsetA (X := X) l k n),
          volume (setA (X := X) (l + 1) k n ∩ L) := by
        congr; rw [← measure_biUnion_finset]
        · congr; ext x; constructor <;> intro h
          · obtain ⟨L', mL'⟩ := dyadic_union h
            have := mem_of_mem_of_subset mL'.1 (mL'.2.trans setA_subset_setA)
            rw [← iUnion_MsetA_eq_setA, mem_iUnion₂] at this
            obtain ⟨M, mM, lM⟩ := this
            obtain ⟨L, mL, lL⟩ := Grid.exists_maximal_supercube mM
            rw [mem_iUnion₂]; use L, mL
            exact ⟨mem_of_mem_of_subset mL'.1 mL'.2, mem_of_mem_of_subset lM lL.1⟩
          · rw [mem_iUnion₂] at h; obtain ⟨i, _, mi₂⟩ := h; exact mem_of_mem_inter_left mi₂
        · exact fun i mi j mj hn ↦
            ((Grid.maxCubes_pairwiseDisjoint mi mj hn).inter_left' _).inter_right' _
        · exact fun _ _ ↦ measurable_setA.inter coeGrid_measurable
      _ ≤ ∑ L ∈ Grid.maxCubes (MsetA (X := X) l k n), volume (L : Set X) := by
        rw [Finset.mul_sum]; exact Finset.sum_le_sum fun L mL ↦ john_nirenberg_aux2 mL
      _ = _ := by
        rw [← measure_biUnion_finset Grid.maxCubes_pairwiseDisjoint (fun _ _ ↦ coeGrid_measurable)]
        congr; ext x; constructor <;> intro h
        · rw [mem_iUnion₂] at h; obtain ⟨i, mi₁, mi₂⟩ := h
          simp only [Grid.maxCubes, Finset.mem_filter, MsetA, Finset.mem_univ, true_and] at mi₁
          exact mem_of_mem_of_subset mi₂ mi₁.1
        · obtain ⟨L', mL'⟩ := dyadic_union h
          have := mem_of_mem_of_subset mL'.1 mL'.2
          rw [← iUnion_MsetA_eq_setA, mem_iUnion₂] at this
          obtain ⟨M, mM, lM⟩ := this
          obtain ⟨L, mL, lL⟩ := Grid.exists_maximal_supercube mM
          rw [mem_iUnion₂]; use L, mL, mem_of_mem_of_subset lM lL.1

/-- An equivalence used in the proof of `second_exception`. -/
def secondExceptionSupportEquiv :
    (support fun n : ℕ ↦ if k < n then (2 : ℝ≥0∞) ^ (-2 * (n - k - 1) : ℤ) else 0) ≃
    support fun n' : ℕ ↦ (2 : ℝ≥0∞) ^ (-2 * n' : ℤ) where
  toFun n := by
    obtain ⟨n, _⟩ := n; use n - k - 1
    rw [mem_support, neg_mul, ← ENNReal.rpow_intCast]; simp
  invFun n' := by
    obtain ⟨n', _⟩ := n'; use n' + k + 1
    simp_rw [mem_support, show k < n' + k + 1 by omega, ite_true, neg_mul, ← ENNReal.rpow_intCast]
    simp
  left_inv n := by
    obtain ⟨n, mn⟩ := n
    rw [mem_support, ne_eq, ite_eq_right_iff, Classical.not_imp] at mn
    simp only [Subtype.mk.injEq]; omega
  right_inv n' := by
    obtain ⟨n', mn'⟩ := n'
    simp only [Subtype.mk.injEq]; omega

/-- Lemma 5.2.6 -/
lemma second_exception : volume (G₂ (X := X)) ≤ 2 ^ (-4 : ℤ) * volume G :=
  calc
    _ ≤ ∑' (n : ℕ), volume (⋃ (k < n), setA (X := X) (2 * n + 6) k n) := measure_iUnion_le _
    _ = ∑' (n : ℕ), volume (⋃ (k : ℕ), if k < n then setA (X := X) (2 * n + 6) k n else ∅) := by
      congr!; exact iUnion_eq_if _
    _ ≤ ∑' (n : ℕ) (k : ℕ), volume (if k < n then setA (X := X) (2 * n + 6) k n else ∅) := by
      gcongr; exact measure_iUnion_le _
    _ = ∑' (k : ℕ) (n : ℕ), if k < n then volume (setA (X := X) (2 * n + 6) k n) else 0 := by
      rw [ENNReal.tsum_comm]; congr!; split_ifs <;> simp
    _ ≤ ∑' (k : ℕ) (n : ℕ), if k < n then 2 ^ (k - 5 - 2 * n : ℤ) * volume G else 0 := by
      gcongr; split_ifs
      · convert john_nirenberg using 3; omega
      · rfl
    _ = ∑' (k : ℕ), 2 ^ (-k - 7 : ℤ) * volume G * ∑' (n' : ℕ), 2 ^ (-2 * n' : ℤ) := by
      congr with k -- n' = n - k - 1; n = n' + k + 1
      have rearr : ∀ n : ℕ, (k - 5 - 2 * n : ℤ) = (-k - 7 + (-2 * (n - k - 1)) : ℤ) := by omega
      conv_lhs =>
        enter [1, n]
        rw [rearr, ENNReal.zpow_add (by simp) (by simp), ← mul_rotate,
          ← mul_zero (volume G * 2 ^ (-k - 7 : ℤ)), ← mul_ite]
      rw [ENNReal.tsum_mul_left, mul_comm (volume G)]; congr 1
      refine Equiv.tsum_eq_tsum_of_support secondExceptionSupportEquiv fun ⟨n, mn⟩ ↦ ?_
      simp_rw [secondExceptionSupportEquiv, Equiv.coe_fn_mk, neg_mul]
      rw [mem_support, ne_eq, ite_eq_right_iff, Classical.not_imp] at mn
      simp_rw [mn.1, ite_true]; congr; omega
    _ ≤ ∑' (k : ℕ), 2 ^ (-k - 7 : ℤ) * volume G * 2 ^ (2 : ℤ) := by
      gcongr
      rw [ENNReal.sum_geometric_two_pow_neg_two, zpow_two]; norm_num
      rw [← ENNReal.coe_ofNat, ← Real.toNNReal_ofNat, ENNReal.coe_le_coe]; norm_num
    _ = 2 ^ (-6 : ℤ) * volume G * 2 ^ (2 : ℤ) := by
      simp_rw [mul_assoc, ENNReal.tsum_mul_right]; congr
      conv_lhs => enter [1, k]; rw [sub_eq_add_neg, ENNReal.zpow_add (by simp) (by simp)]
      nth_rw 1 [ENNReal.tsum_mul_right, ENNReal.sum_geometric_two_pow_neg_one,
        ← zpow_one 2, ← ENNReal.zpow_add] <;> simp
    _ = _ := by rw [← mul_rotate, ← ENNReal.zpow_add] <;> simp

section TopTiles

/-- The volume of a "layer" in the key function of Lemma 5.2.7. -/
def layervol (k n : ℕ) (t : ℝ) : ℝ≥0∞ :=
  volume {x | t ≤ ∑ m ∈ Finset.univ.filter (· ∈ 𝔐 (X := X) k n),
    (𝓘 m : Set X).indicator (1 : X → ℝ) x}

lemma indicator_sum_eq_natCast {s : Finset (𝔓 X)} :
    ∑ m ∈ s, (𝓘 m : Set X).indicator (1 : X → ℝ) x =
    Nat.cast (∑ m ∈ s, (𝓘 m : Set X).indicator (1 : X → ℕ) x) := by
  push_cast; congr!; simp [indicator]

lemma layervol_eq_zero_of_lt {t : ℝ} (ht : (𝔐 (X := X) k n).toFinset.card < t) :
    layervol (X := X) k n t = 0 := by
  rw [layervol, measure_zero_iff_ae_nmem]
  refine ae_of_all volume fun x ↦ ?_; rw [mem_setOf, not_le]
  calc
    _ ≤ ((𝔐 (X := X) k n).toFinset.card : ℝ) := by
      simp_rw [indicator_sum_eq_natCast, Nat.cast_le, indicator_apply, Pi.one_apply,
        Finset.sum_boole, Nat.cast_id, filter_mem_univ_eq_toFinset]
      exact Finset.card_le_card (Finset.filter_subset ..)
    _ < _ := ht

lemma lintegral_Ioc_layervol_one {l : ℕ} :
    ∫⁻ t in Ioc (l : ℝ) (l + 1), layervol (X := X) k n t = layervol (X := X) k n (l + 1) :=
  calc
    _ = ∫⁻ t in Ioc (l : ℝ) (l + 1), layervol (X := X) k n (l + 1) := by
      refine setLIntegral_congr_fun measurableSet_Ioc (ae_of_all volume fun t mt ↦ ?_)
      unfold layervol; congr; ext x; simp_rw [mem_setOf]; constructor <;> intro h
      · rw [indicator_sum_eq_natCast, ← Nat.cast_one, ← Nat.cast_add, Nat.cast_le]
        rw [indicator_sum_eq_natCast, ← Nat.ceil_le] at h; convert h; symm
        rwa [Nat.ceil_eq_iff (by omega), add_tsub_cancel_right, Nat.cast_add, Nat.cast_one]
      · exact mt.2.trans h
    _ = layervol k n (l + 1) * volume (Ioc (l : ℝ) (l + 1)) := setLIntegral_const ..
    _ = _ := by rw [Real.volume_Ioc, add_sub_cancel_left, ENNReal.ofReal_one, mul_one]

lemma antitone_layervol : Antitone fun t ↦ layervol (X := X) k n t := fun i j h ↦ by
  unfold layervol; exact measure_mono fun x hx ↦ h.trans hx

lemma lintegral_Ioc_layervol_le {a b : ℕ} : ∫⁻ t in Ioc (a : ℝ) b, layervol (X := X) k n t ≤
    (b - a : ℕ) * layervol (X := X) k n (a + 1) := by
  calc
    _ = ∑ l ∈ Finset.Ico a b, ∫⁻ t in Ioc (l : ℝ) (l + 1), layervol (X := X) k n t := by
      nth_rw 1 [← mul_one (a : ℝ), ← mul_one (b : ℝ)]
      convert lintegral_Ioc_partition zero_le_one using 4; simp
    _ = ∑ l ∈ Finset.Ico a b, layervol (X := X) k n (l + 1) := by
      congr! 2; exact lintegral_Ioc_layervol_one
    _ ≤ ∑ l ∈ Finset.Ico a b, layervol (X := X) k n (a + 1) :=
      Finset.sum_le_sum fun l ml ↦ antitone_layervol (by simp_all)
    _ = _ := by rw [Finset.sum_const, Nat.card_Ico, nsmul_eq_mul]

lemma top_tiles_aux : ∑ m ∈ Finset.univ.filter (· ∈ 𝔐 (X := X) k n), volume (𝓘 m : Set X) =
    ∫⁻ t in Ioc 0 ((𝔐 (X := X) k n).toFinset.card * 2 ^ (n + 1) : ℝ), layervol (X := X) k n t := by
  set M := 𝔐 (X := X) k n
  set Mc := M.toFinset.card
  calc
    _ = ∑ m ∈ Finset.univ.filter (· ∈ M), ∫⁻ x, (𝓘 m : Set X).indicator 1 x := by
      congr! with m; exact (lintegral_indicator_one coeGrid_measurable).symm
    _ = ∫⁻ x, ∑ m ∈ Finset.univ.filter (· ∈ M), (𝓘 m : Set X).indicator 1 x :=
      (lintegral_finset_sum _ fun _ _ ↦ measurable_one.indicator coeGrid_measurable).symm
    _ = ∫⁻ x, ENNReal.ofReal (∑ m ∈ Finset.univ.filter (· ∈ M), (𝓘 m : Set X).indicator 1 x) := by
      congr! 2 with x; rw [ENNReal.ofReal_sum_of_nonneg]
      · congr!; unfold indicator; split_ifs <;> simp
      · exact fun _ _ ↦ indicator_nonneg (fun _ _ ↦ by simp) _
    _ = ∫⁻ t in Ioi 0, layervol k n t := by
      apply lintegral_eq_lintegral_meas_le
      · exact ae_of_all volume fun _ ↦
          Finset.sum_nonneg' fun _ ↦ indicator_nonneg (fun _ _ ↦ by simp) _
      · exact Measurable.aemeasurable <|
          Finset.measurable_sum _ (fun _ _ ↦ measurable_one.indicator coeGrid_measurable)
    _ = _ := by
      have nn : 0 ≤ (Mc * 2 ^ (n + 1) : ℝ) := by positivity
      rw [← Ioc_union_Ioi_eq_Ioi nn, lintegral_union measurableSet_Ioi Ioc_disjoint_Ioi_same]
      nth_rw 3 [← add_zero (lintegral ..)]; congr 1
      have cgr : ∫⁻ (t : ℝ) in Ioi (Mc * 2 ^ (n + 1) : ℝ), layervol (X := X) k n t =
          ∫⁻ _ in Ioi (Mc * 2 ^ (n + 1) : ℝ), 0 := by
        refine setLIntegral_congr_fun measurableSet_Ioi (ae_of_all volume fun t mt ↦
          layervol_eq_zero_of_lt (lt_of_le_of_lt ?_ mt))
        exact_mod_cast Nat.le_mul_of_pos_right Mc (by positivity)
      rw [cgr, lintegral_zero]

/-- Lemma 5.2.7 -/
lemma top_tiles : ∑ m ∈ Finset.univ.filter (· ∈ 𝔐 (X := X) k n), volume (𝓘 m : Set X) ≤
    2 ^ (n + k + 3) * volume G := by
  set M := 𝔐 (X := X) k n
  let Mc := M.toFinset.card
  calc
    _ = ∫⁻ t in Ioc 0 (Mc * 2 ^ (n + 1) : ℝ), layervol (X := X) k n t := top_tiles_aux
    _ = ∑ l ∈ Finset.range Mc,
        ∫⁻ t in Ioc ((l : ℝ) * 2 ^ (n + 1)) ((l + 1 : ℕ) * 2 ^ (n + 1)),
          layervol (X := X) k n t := by
      rw [Finset.range_eq_Ico, show (0 : ℝ) = (0 : ℕ) * 2 ^ (n + 1) by simp]
      exact lintegral_Ioc_partition (by positivity)
    _ ≤ ∑ l ∈ Finset.range Mc,
        (((l + 1) * 2 ^ (n + 1) - l * 2 ^ (n + 1) : ℕ)) *
          layervol (X := X) k n ((l * 2 ^ (n + 1) : ℕ) + 1) := by
      convert Finset.sum_le_sum fun _ _ ↦ lintegral_Ioc_layervol_le <;> simp
    _ = 2 ^ (n + 1) * ∑ l ∈ Finset.range Mc, layervol (X := X) k n (l * 2 ^ (n + 1) + 1 : ℕ) := by
      rw [Finset.mul_sum]; congr! 2
      · rw [← Nat.mul_sub_right_distrib]; simp
      · congr; simp
    _ = 2 ^ (n + 1) * ∑ l ∈ Finset.range Mc, volume (setA (X := X) l k n) := by
      unfold layervol setA stackSize; congr! 3; ext x
      rw [mem_setOf, mem_setOf, indicator_sum_eq_natCast, Nat.cast_le]
      exact Nat.add_one_le_iff
    _ ≤ 2 ^ (n + 1) * ∑ l ∈ Finset.range Mc, 2 ^ (k + 1 - l : ℤ) * volume G :=
      mul_le_mul_left' (Finset.sum_le_sum fun _ _ ↦ john_nirenberg) _
    _ ≤ 2 ^ (n + 1) * ∑' (l : ℕ), 2 ^ (k + 1 - l : ℤ) * volume G :=
      mul_le_mul_left' (ENNReal.sum_le_tsum _) _
    _ = 2 ^ (n + 1) * (volume G * 2 ^ (k + 1) * 2) := by
      conv_lhs =>
        enter [2, 1, l]
        rw [sub_eq_add_neg, ENNReal.zpow_add (by simp) (by simp), ← mul_rotate]
      rw [ENNReal.tsum_mul_left]; congr 3
      · norm_cast
      · exact ENNReal.sum_geometric_two_pow_neg_one
    _ = _ := by
      nth_rw 3 [← pow_one 2]
      rw [mul_rotate, ← pow_add, ← mul_assoc, ← pow_add,
        show n + 1 + (k + 1 + 1) = n + k + 3 by omega]

end TopTiles

section 𝔘
-- Definition of function `𝔘(m)` used in the proof of Lemma 5.2.8, and some properties of `𝔘(m)`

open Finset

variable (k) (n) (j) (x)
private def 𝔘 (m : 𝔓 X) := (𝔘₁ k n j).toFinset.filter (fun u ↦ x ∈ 𝓘 u ∧ smul 100 u ≤ smul 1 m)

-- Ball that covers the image of `𝒬`. Radius chosen for convenience with `BallsCoverBalls.pow_mul`
private def big_ball (m : 𝔓 X) (u : 𝔓 X) := ball_(u) (𝒬 m) (2 ^ 9 * 0.2)

variable {k} {n} {j} {x}
variable {x : X} {m u u' u'' : 𝔓 X}
variable (hu : u ∈ 𝔘 k n j x m) (hu' : u' ∈ 𝔘 k n j x m) (hu'' : u'' ∈ 𝔘 k n j x m)

private lemma x_mem_𝓘u : x ∈ (𝓘 u) := by
  simp only [𝔘, mem_filter] at hu
  exact hu.2.1

private lemma 𝒬m_mem_ball : 𝒬 m ∈ ball_(u) (𝒬 u) 100 := by
  simp only [𝔘, mem_filter, smul] at hu
  exact hu.2.2.2 (by simp)

private lemma 𝓘_not_lt_𝓘 : ¬ 𝓘 u < 𝓘 u' := by
  intro h
  rw [Grid.lt_def] at h
  have 𝒬m_mem_inter := mem_inter (𝒬m_mem_ball hu) (𝒬m_mem_ball hu')
  simp only [𝔘, 𝔘₁, Grid.lt_def, and_imp, toFinset_setOf, mem_filter] at hu
  exact not_disjoint_iff_nonempty_inter.2 (nonempty_of_mem 𝒬m_mem_inter) <| hu.1.2.2
    u' (mem_toFinset.mp (mem_filter.mp hu').1).1 h.1 h.2

private lemma 𝓘_eq_𝓘 : 𝓘 u = 𝓘 u' :=
  have not_disj := Set.not_disjoint_iff.mpr ⟨x, ⟨x_mem_𝓘u hu, x_mem_𝓘u hu'⟩⟩
  le_or_ge_or_disjoint.elim (fun h ↦ (h.lt_or_eq).resolve_left (𝓘_not_lt_𝓘 hu hu'))
    (fun h ↦ ((h.resolve_right not_disj).lt_or_eq.resolve_left (𝓘_not_lt_𝓘 hu' hu)).symm)

private lemma ball_eq_ball : ball_(u) = ball_(u') := by
  rw [𝔠, 𝔰, 𝓘_eq_𝓘 hu hu']

private lemma disjoint_balls (h : u' ≠ u'') :
    Disjoint (ball_(u) (𝒬 u') 0.2) (ball_(u) (𝒬 u'') 0.2) := by
  nth_rewrite 1 [ball_eq_ball hu hu', ball_eq_ball hu hu'']
  convert cball_disjoint h (𝓘_eq_𝓘 hu' hu'') using 2 <;> norm_num

private lemma mem_big_ball : 𝒬 u' ∈ big_ball m u := by
  have : 𝒬 m ∈ ball_(u) (𝒬 u') 100 := ball_eq_ball hu hu' ▸ 𝒬m_mem_ball hu'
  rw [@mem_ball_comm] at this
  simp only [big_ball, mem_ball] at this ⊢
  exact this.trans (by norm_num)

private lemma subset_big_ball (f : Θ X) (hf : f ∈ (𝔘 k n j x m).image 𝒬) : f ∈ big_ball m u := by
  simp_rw [Finset.mem_image] at hf
  rcases hf with ⟨u', hu', rfl⟩
  exact mem_big_ball hu hu'

variable (m) (u : 𝔓 X) in
private lemma balls_cover_big_ball : CoveredByBalls (big_ball m u) (defaultA a ^ 9) 0.2 :=
  BallsCoverBalls.pow_mul (fun _ ↦ CompatibleFunctions.ballsCoverBalls) (𝒬 m)

private lemma 𝒬_injOn_𝔘m : InjOn 𝒬 (𝔘 k n j x m).toSet :=
  fun _ hu _ hu' h ↦ 𝒬_inj h (𝓘_eq_𝓘 hu hu')

private lemma card_𝔘m_le : (𝔘 k n j x m).card ≤ (defaultA a) ^ 9 := by
  by_cases h : 𝔘 k n j x m = ∅
  · simp [h]
  have ⟨u, hu⟩ := Finset.nonempty_of_ne_empty h
  let pm := instPseudoMetricSpaceWithFunctionDistance (x := 𝔠 u) (r := (D ^ 𝔰 u / 4))
  have ⟨𝓑, 𝓑_card_le, 𝓑_cover⟩ := balls_cover_big_ball m u
  let 𝓕 (f : Θ X) := ((𝔘 k n j x m).image 𝒬).filter (· ∈ @ball _ pm f 0.2)
  -- `𝒬` is 1-1, `𝓑.biUnion 𝓕` covers `(𝔘 k n j x m).image 𝒬`, and each `𝓕 f` has cardinality
  -- ≤ 1, so `(𝔘 k n j x m).card = ((𝔘 k n j x m).image 𝒬).card ≤ (𝓑.biUnion 𝓕).card ≤ 𝓑.card`
  have 𝒬𝔘_eq_union: (𝔘 k n j x m).image 𝒬 = 𝓑.biUnion 𝓕 := by
    ext f
    simp only [𝓕, Finset.mem_biUnion, mem_filter]
    refine ⟨fun hf ↦ ?_, fun ⟨_, _, h, _⟩ ↦ h⟩
    obtain ⟨g, hg⟩ : ∃ g ∈ 𝓑, f ∈ @ball _ pm g 0.2 := by
      simpa only [mem_iUnion, exists_prop] using 𝓑_cover (subset_big_ball hu f hf)
    exact ⟨g, hg.1, hf, hg.2⟩
  have card_le_one : ∀ f ∈ 𝓑, (𝓕 f).card ≤ 1 := by
    refine fun f _ ↦ card_le_one.mpr (fun g₁ hg₁ g₂ hg₂ ↦ ?_)
    by_contra! h
    simp only [mem_filter, 𝓕, Finset.mem_image] at hg₁ hg₂
    rcases hg₁.1 with ⟨u₁, hu₁, rfl⟩
    rcases hg₂.1 with ⟨u₂, hu₂, rfl⟩
    apply Set.not_disjoint_iff.mpr ⟨f, mem_ball_comm.mp hg₁.2, mem_ball_comm.mp hg₂.2⟩
    exact disjoint_balls hu hu₁ hu₂ (ne_of_apply_ne 𝒬 h)
  rw [← card_image_iff.mpr 𝒬_injOn_𝔘m, 𝒬𝔘_eq_union]
  exact (mul_one 𝓑.card ▸ card_biUnion_le_card_mul 𝓑 𝓕 1 card_le_one).trans 𝓑_card_le

variable (k n j) (x) in
private def 𝔐' (u : 𝔓 X) := (𝔐 k n).toFinset.filter (fun m ↦ smul 100 u ≤ smul 1 m)

-- Interchange the summations in the proof of Lemma 5.2.8
private lemma interchange :
    ((𝔘₁ k n j).toFinset.filter (x ∈ 𝓘 ·)).sum (fun u ↦ (𝔐' k n u).sum
    (fun m ↦ (𝓘 m : Set X).indicator (1 : X → ℝ) x)) =
    (𝔐 k n).toFinset.sum (fun m ↦ (𝔘 k n j x m).sum
    (fun _ ↦ (𝓘 m : Set X).indicator (1 : X → ℝ) x)) :=
  Finset.sum_comm' fun u m ↦ by simp only [𝔐', 𝔘, Finset.mem_filter]; tauto

end 𝔘

-- Inequality (5.2.20) in the proof of Lemma 5.2.8
private lemma indicator_le : ∀ u ∈ (𝔘₁ k n j).toFinset.filter (x ∈ 𝓘 ·),
    (𝓘 u : Set X).indicator 1 x ≤ (2 : ℝ) ^ (-j : ℤ) * stackSize (𝔐' k n u) x := by
  intro u hu
  by_cases hx : x ∈ (𝓘 u : Set X); swap
  · simp [hx]
  suffices (2 : ℝ) ^ (j : ℤ) ≤ stackSize (𝔐' k n u) x by calc
    _ ≤ (2 : ℝ) ^ (-j : ℤ) * (2 : ℝ) ^ (j : ℤ)       := by simp [hx]
    _ ≤ (2 : ℝ) ^ (-j : ℤ) * stackSize (𝔐' k n u) x := by gcongr
  norm_cast
  simp only [𝔘₁, Finset.mem_filter, toFinset_setOf] at hu
  apply le_of_le_of_eq hu.1.2.1.1.2
  simp only [Finset.coe_filter, mem_toFinset, 𝔐', Finset.card_eq_sum_ones]
  refine Finset.sum_congr rfl (fun m hm ↦ ?_)
  simp only [TileLike.le_def, smul_fst, Finset.mem_filter] at hm
  simp [hm.2.2.1.1 hx]

open Finset in
/-- Lemma 5.2.8 -/
lemma tree_count :
    stackSize (𝔘₁ k n j) x ≤ (2 : ℝ) ^ (9 * a - j : ℤ) * stackSize (𝔐 k n) x := by
  -- When calculating the LHS, we need only sum over those `u` for which `x ∈ 𝓘 u`.
  have : ∑ u ∈ univ.filter (· ∈ 𝔘₁ (X := X) k n j), (𝓘 u : Set X).indicator (1 : X → ℝ) x =
      ∑ u ∈ (𝔘₁ k n j).toFinset.filter (x ∈ 𝓘 ·), (𝓘 u : Set X).indicator (1 : X → ℝ) x := by
    rw [filter_mem_univ_eq_toFinset (𝔘₁ k n j), sum_filter]
    exact sum_congr rfl <|
      fun u _ ↦ _root_.by_cases (p := x ∈ 𝓘 u) (fun hx ↦ by simp [hx]) (fun hx ↦ by simpa [hx])
  rw [stackSize_real, this]
  -- Use inequality (5.2.20) to bound the LHS by a double sum, then interchange the sums.
  apply le_trans (sum_le_sum indicator_le)
  simp_rw [← mul_sum, stackSize_real, mem_coe, filter_univ_mem, interchange, sum_const]
  -- Replace the cardinality of `𝔘` with the upper bound proven in `card_𝔘m_le`, and simplify.
  apply le_of_le_of_eq <| (mul_le_mul_left (zpow_pos_of_pos two_pos _)).mpr <| sum_le_sum <|
    fun _ _ ↦ smul_le_smul_of_nonneg_right card_𝔘m_le <| Set.indicator_apply_nonneg (by simp)
  simp_rw [← smul_sum, nsmul_eq_mul, ← mul_assoc, filter_mem_univ_eq_toFinset (𝔐 k n), defaultA]
  rw [sub_eq_add_neg, zpow_add₀ two_ne_zero, ← pow_mul, mul_comm 9, mul_comm (2 ^ _)]
  norm_cast

variable (X) in
/-- The constant in Lemma 5.2.9, with value `D ^ (1 - κ * Z * (n + 1))` -/
def C5_2_9 [ProofData a q K σ₁ σ₂ F G] (n : ℕ) : ℝ≥0 := D ^ (1 - κ * Z * (n + 1))

/-- Lemma 5.2.9 -/
lemma boundary_exception {u : 𝔓 X} (hu : u ∈ 𝔘₁ k n l) :
    volume (⋃ i ∈ 𝓛 (X := X) n u, (i : Set X)) ≤ C5_2_9 X n * volume (𝓘 u : Set X) := by
  sorry

/-- Lemma 5.2.10 -/
lemma third_exception : volume (G₃ (X := X)) ≤ 2 ^ (- 4 : ℤ) * volume G := by
  sorry

/-- Lemma 5.1.1 -/
lemma exceptional_set : volume (G' : Set X) ≤ 2 ^ (- 2 : ℤ) * volume G :=
  calc volume G'
    _ ≤ volume G₁ + volume G₂ + volume G₃ :=
      le_add_of_le_add_right (measure_union_le _ G₃) (measure_union_le _ _)
    _ ≤ 2 ^ (- 4 : ℤ) * volume G + 2 ^ (- 4 : ℤ) * volume G + 2 ^ (- 4 : ℤ) * volume G :=
      add_le_add_three first_exception second_exception third_exception
    _ = (3 : ℝ≥0∞) * 2 ^ (-4 : ℤ) * volume G := by ring
    _ ≤ 2 ^ (- 2 : ℤ) * volume G :=
      have coefficient_inequality : (3 : ℝ≥0∞) * 2 ^ (-4 : ℤ) ≤ (2 : ℝ≥0∞) ^ (-2 : ℤ) := by
        change ((3 : ℝ≥0) : ℝ≥0∞) * (2 : ℝ≥0) ^ (-4 : ℤ) ≤ (2 : ℝ≥0) ^ (-2 : ℤ)
        repeat rw [← ENNReal.coe_zpow (show (2 : ℝ≥0) ≠ 0 by norm_num)]
        rw_mod_cast [← NNReal.coe_le_coe]; norm_num
      mul_le_mul_right' coefficient_inequality _

/-! ## Section 5.3 -/

/-! Note: the lemmas 5.3.1-5.3.3 are in `TileStructure`. -/

/-- Lemma 5.3.4 -/
lemma ordConnected_tilesAt : OrdConnected (TilesAt k : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  simp_rw [TilesAt, mem_preimage, 𝓒, mem_diff, aux𝓒, mem_setOf] at mp mp'' ⊢
  constructor
  · obtain ⟨J, hJ, _⟩ := mp''.1
    use J, mp'.2.1.trans hJ
  · push_neg at mp ⊢
    exact fun J hJ ↦ mp.2 J (mp'.1.1.trans hJ)

/-- Lemma 5.3.5 -/
lemma ordConnected_C : OrdConnected (ℭ k n : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  rw [ℭ, mem_setOf] at mp mp'' ⊢
  have z := mem_of_mem_of_subset mp' (ordConnected_tilesAt.out mp.1 mp''.1)
  refine ⟨z, ?_⟩
  have : ∀ q' ∈ TilesAt (X := X) k, ∀ q ≤ q', dens' k {q'} ≤ dens' k {q} := fun q' _ q hq ↦ by
    simp_rw [dens', mem_singleton_iff, iSup_iSup_eq_left]; gcongr with l hl a _
    exact iSup_const_mono fun h ↦
      wiggle_order_11_10 hq (C5_3_3_le (X := X).trans (by norm_num) |>.trans hl) |>.trans h
  exact ⟨mp''.2.1.trans_le (this _ mp''.1 _ mp'.2), (this _ z _ mp'.1).trans mp.2.2⟩

/-- Lemma 5.3.6 -/
lemma ordConnected_C1 : OrdConnected (ℭ₁ k n j : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  have mp'₁ : p' ∈ ℭ (X := X) k n := mem_of_mem_of_subset mp'
    (ordConnected_C.out (mem_of_mem_of_subset mp ℭ₁_subset_ℭ)
      (mem_of_mem_of_subset mp'' ℭ₁_subset_ℭ))
  simp_rw [ℭ₁, mem_diff, preℭ₁, mem_setOf, not_and, not_le] at mp mp'' ⊢
  simp_rw [mp.1.1, true_and, true_implies] at mp
  simp_rw [mp'₁, true_and, true_implies]
  simp_rw [mp''.1.1, true_and, true_implies] at mp''
  constructor
  · refine mp''.1.trans (Finset.card_le_card fun b mb ↦ ?_)
    simp_rw [Finset.mem_filter, Finset.mem_univ, true_and, 𝔅, mem_setOf] at mb ⊢
    have := wiggle_order_11_10 (n := 100) mp'.2 (C5_3_3_le (X := X).trans (by norm_num))
    exact ⟨mb.1, this.trans mb.2⟩
  · refine (Finset.card_le_card fun b mb ↦ ?_).trans_lt mp.2
    simp_rw [Finset.mem_filter, Finset.mem_univ, true_and, 𝔅, mem_setOf] at mb ⊢
    have := wiggle_order_11_10 (n := 100) mp'.1 (C5_3_3_le (X := X).trans (by norm_num))
    exact ⟨mb.1, this.trans mb.2⟩

/-- Lemma 5.3.7 -/
lemma ordConnected_C2 : OrdConnected (ℭ₂ k n j : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  have mp₁ := mem_of_mem_of_subset mp ℭ₂_subset_ℭ₁
  have mp'₁ : p' ∈ ℭ₁ (X := X) k n j := mem_of_mem_of_subset mp'
    (ordConnected_C1.out mp₁ (mem_of_mem_of_subset mp'' ℭ₂_subset_ℭ₁))
  by_cases e : p = p'; · rwa [e] at mp
  simp_rw [ℭ₂, mem_diff, mp'₁, true_and]
  by_contra h; rw [mem_iUnion₂] at h; obtain ⟨l', bl', p'm⟩ := h
  rw [𝔏₁, mem_minimals_iff] at p'm
  have pnm : p ∉ ⋃ l'', ⋃ (_ : l'' < l'), 𝔏₁ k n j l'' := by
    replace mp := mp.2; contrapose! mp
    exact mem_of_mem_of_subset mp
      (iUnion_mono'' fun i ↦ iUnion_subset_iUnion_const fun hi ↦ (hi.trans_le bl').le)
  exact absurd (p'm.2 ⟨mp.1, pnm⟩ mp'.1).symm e

/-- Lemma 5.3.8 -/
lemma ordConnected_C3 : OrdConnected (ℭ₃ k n j : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  have mp₁ := mem_of_mem_of_subset mp ℭ₃_subset_ℭ₂
  have mp''₁ := mem_of_mem_of_subset mp'' ℭ₃_subset_ℭ₂
  have mp'₁ : p' ∈ ℭ₂ (X := X) k n j := mem_of_mem_of_subset mp' (ordConnected_C2.out mp₁ mp''₁)
  simp_rw [ℭ₃, mem_diff, mp''₁, mp'₁, true_and, 𝔏₂, mem_setOf,
    mp''₁, mp'₁, true_and, not_not] at mp'' ⊢
  obtain ⟨u, mu, 𝓘nu, su⟩ := mp''; use u, mu
  exact ⟨(mp'.2.1.trans_lt (lt_of_le_of_ne su.1 𝓘nu)).ne,
    (wiggle_order_11_10 mp'.2 (C5_3_3_le (X := X).trans (by norm_num))).trans su⟩

/-- Lemma 5.3.9 -/
lemma ordConnected_C4 : OrdConnected (ℭ₄ k n j : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  have mp''₁ := mem_of_mem_of_subset mp'' ℭ₄_subset_ℭ₃
  have mp'₁ : p' ∈ ℭ₃ (X := X) k n j := mem_of_mem_of_subset mp'
    (ordConnected_C3.out (mem_of_mem_of_subset mp ℭ₄_subset_ℭ₃) mp''₁)
  by_cases e : p' = p''; · rwa [← e] at mp''
  simp_rw [ℭ₄, mem_diff, mp'₁, true_and]
  by_contra h; simp_rw [mem_iUnion] at h; obtain ⟨l', hl', p'm⟩ := h
  rw [𝔏₃, mem_maximals_iff] at p'm; simp_rw [mem_diff] at p'm
  have p''nm : p'' ∉ ⋃ l'', ⋃ (_ : l'' < l'), 𝔏₃ k n j l'' := by
    replace mp'' := mp''.2; contrapose! mp''
    refine mem_of_mem_of_subset mp'' <| iUnion₂_mono' fun i hi ↦ ⟨i, hi.le.trans hl', subset_rfl⟩
  exact absurd (p'm.2 ⟨mp''₁, p''nm⟩ mp'.2) e

/-- Lemma 5.3.10 -/
lemma ordConnected_C5 : OrdConnected (ℭ₅ k n j : Set (𝔓 X)) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  have mp₁ := mem_of_mem_of_subset mp ℭ₅_subset_ℭ₄
  have mp'₁ : p' ∈ ℭ₄ (X := X) k n j := mem_of_mem_of_subset mp'
    (ordConnected_C4.out mp₁ (mem_of_mem_of_subset mp'' ℭ₅_subset_ℭ₄))
  simp_rw [ℭ₅, mem_diff, mp₁, mp'₁, true_and, 𝔏₄, mem_setOf,
    mp₁, mp'₁, true_and] at mp ⊢
  contrapose! mp; obtain ⟨u, mu, s𝓘u⟩ := mp; use u, mu, mp'.1.1.1.trans s𝓘u

/-- Lemma 5.3.11 -/
lemma dens1_le_dens' {P : Set (𝔓 X)} (hP : P ⊆ TilesAt k) : dens₁ P ≤ dens' k P := by
  rw [dens₁, dens']; gcongr with p' mp' l hl
  simp_rw [ENNReal.mul_iSup, iSup_le_iff, mul_div_assoc]; intro p mp sl
  suffices p ∈ TilesAt k by
    exact le_iSup_of_le p (le_iSup₂_of_le this sl (mul_le_mul' (by norm_cast) le_rfl))
  simp_rw [TilesAt, mem_preimage, 𝓒, mem_diff, aux𝓒, mem_setOf]
  constructor
  · rw [mem_lowerClosure] at mp; obtain ⟨p'', mp'', lp''⟩ := mp
    have := mem_of_mem_of_subset mp'' hP
    simp_rw [TilesAt, mem_preimage, 𝓒, mem_diff, aux𝓒, mem_setOf] at this
    obtain ⟨J, lJ, vJ⟩ := this.1; use J, lp''.1.trans lJ
  · by_contra h; obtain ⟨J, lJ, vJ⟩ := h
    have := mem_of_mem_of_subset mp' hP
    simp_rw [TilesAt, mem_preimage, 𝓒, mem_diff, aux𝓒, mem_setOf] at this
    apply absurd _ this.2; use J, sl.1.trans lJ

/-- Lemma 5.3.12 -/
lemma dens1_le {A : Set (𝔓 X)} (hA : A ⊆ ℭ k n) : dens₁ A ≤ 2 ^ (4 * a - n + 1) :=
  calc
    _ ≤ dens' k A := dens1_le_dens' (hA.trans ℭ_subset_TilesAt)
    _ ≤ dens' k (ℭ (X := X) k n) := iSup_le_iSup_of_subset hA
    _ ≤ _ := by
      rw [dens'_iSup, iSup₂_le_iff]; intro p mp
      rw [ℭ, mem_setOf] at mp; exact mp.2.2

/-! ## Section 5.4 and Lemma 5.1.2 -/

/-- The subset `ℭ₆(k, n, j)` of `ℭ₅(k, n, j)`, given above (5.4.1). -/
def ℭ₆ (k n j : ℕ) : Set (𝔓 X) :=
  { p ∈ ℭ₅ k n j | ¬ (𝓘 p : Set X) ⊆ G' }

lemma ℭ₆_subset_ℭ₅ : ℭ₆ (X := X) k n j ⊆ ℭ₅ k n j := sep_subset ..
lemma ℭ₆_subset_ℭ : ℭ₆ (X := X) k n j ⊆ ℭ k n :=
  ℭ₆_subset_ℭ₅ |>.trans ℭ₅_subset_ℭ₄ |>.trans ℭ₄_subset_ℭ₃ |>.trans ℭ₃_subset_ℭ₂ |>.trans
    ℭ₂_subset_ℭ₁ |>.trans ℭ₁_subset_ℭ

/-- The subset `𝔗₁(u)` of `ℭ₁(k, n, j)`, given in (5.4.1).
In lemmas, we will assume `u ∈ 𝔘₁ k n l` -/
def 𝔗₁ (k n j : ℕ) (u : 𝔓 X) : Set (𝔓 X) :=
  { p ∈ ℭ₁ k n j | 𝓘 p ≠ 𝓘 u ∧ smul 2 p ≤ smul 1 u }

/-- The subset `𝔘₂(k, n, j)` of `𝔘₁(k, n, j)`, given in (5.4.2). -/
def 𝔘₂ (k n j : ℕ) : Set (𝔓 X) :=
  { u ∈ 𝔘₁ k n j | ¬ Disjoint (𝔗₁ k n j u) (ℭ₆ k n j) }

lemma 𝔘₂_subset_𝔘₁ : 𝔘₂ k n j ⊆ 𝔘₁ (X := X) k n j := fun _ mu ↦ mu.1

/-- The relation `∼` defined below (5.4.2). It is an equivalence relation on `𝔘₂ k n j`. -/
def URel (k n j : ℕ) (u u' : 𝔓 X) : Prop :=
  u = u' ∨ ∃ p ∈ 𝔗₁ k n j u, smul 10 p ≤ smul 1 u'

nonrec lemma URel.rfl : URel k n j u u := Or.inl rfl

/-- Lemma 5.4.1, part 2. -/
lemma URel.not_disjoint (hu : u ∈ 𝔘₂ k n j) (hu' : u' ∈ 𝔘₂ k n j) (huu' : URel k n j u u') :
    ¬Disjoint (ball_(u) (𝒬 u) 100) (ball_(u') (𝒬 u') 100) := by
  by_cases e : u = u'; · rw [e]; simp
  simp_rw [URel, e, false_or, 𝔗₁, mem_setOf] at huu'; obtain ⟨p, ⟨mp, np, sl₁⟩, sl₂⟩ := huu'
  by_cases e' : 𝓘 p = 𝓘 u'
  · refine not_disjoint_iff.mpr ⟨𝒬 u, mem_ball_self (by positivity), ?_⟩
    rw [@mem_ball]
    have i1 : ball_{𝓘 u} (𝒬 u) 1 ⊆ ball_{𝓘 p} (𝒬 p) 2 := sl₁.2
    have i2 : ball_{𝓘 u'} (𝒬 u') 1 ⊆ ball_{𝓘 p} (𝒬 p) 10 := sl₂.2
    replace i1 : 𝒬 u ∈ ball_{𝓘 p} (𝒬 p) 2 := i1 (mem_ball_self zero_lt_one)
    replace i2 : 𝒬 u' ∈ ball_{𝓘 p} (𝒬 p) 10 := i2 (mem_ball_self zero_lt_one)
    rw [e', @mem_ball] at i1 i2
    calc
      _ ≤ dist_{𝓘 u'} (𝒬 u) (𝒬 p) + dist_{𝓘 u'} (𝒬 u') (𝒬 p) := dist_triangle_right ..
      _ < 2 + 10 := add_lt_add i1 i2
      _ < 100 := by norm_num
  have plu : smul 100 p ≤ smul 100 u := wiggle_order_100 (smul_mono sl₁ le_rfl (by norm_num)) np
  have plu' : smul 100 p ≤ smul 100 u' := wiggle_order_100 sl₂ e'
  by_contra h
  have 𝔅dj : Disjoint (𝔅 k n u) (𝔅 k n u') := by
    simp_rw [𝔅, disjoint_left, mem_setOf, not_and]; intro q ⟨_, sl⟩ _
    simp_rw [TileLike.le_def, smul_fst, smul_snd, not_and_or] at sl ⊢; right
    have := disjoint_left.mp (h.mono_left sl.2) (mem_ball_self zero_lt_one)
    rw [not_subset]; use 𝒬 q, mem_ball_self zero_lt_one
  have usp : 𝔅 k n u ⊆ 𝔅 k n p := fun q mq ↦ by
    rw [𝔅, mem_setOf] at mq ⊢; exact ⟨mq.1, plu.trans mq.2⟩
  have u'sp : 𝔅 k n u' ⊆ 𝔅 k n p := fun q mq ↦ by
    rw [𝔅, mem_setOf] at mq ⊢; exact ⟨mq.1, plu'.trans mq.2⟩
  rw [𝔘₂, mem_setOf, 𝔘₁, mem_setOf] at hu hu'
  apply absurd (card_𝔅_of_mem_ℭ₁ mp).2; rw [not_lt]
  calc
    _ = 2 ^ j + 2 ^ j := Nat.two_pow_succ j
    _ ≤ (𝔅 k n u).toFinset.card + (𝔅 k n u').toFinset.card :=
      add_le_add (card_𝔅_of_mem_ℭ₁ hu.1.1).1 (card_𝔅_of_mem_ℭ₁ hu'.1.1).1
    _ = (𝔅 k n u ∪ 𝔅 k n u').toFinset.card := by
      rw [toFinset_union]; refine (Finset.card_union_of_disjoint ?_).symm
      simpa using 𝔅dj
    _ ≤ _ := by
      apply Finset.card_le_card
      simp_rw [toFinset_union, subset_toFinset, Finset.coe_union, coe_toFinset, union_subset_iff]
      exact ⟨usp, u'sp⟩

/-- Lemma 5.4.1, part 1. -/
lemma URel.eq (hu : u ∈ 𝔘₂ k n j) (hu' : u' ∈ 𝔘₂ k n j) (huu' : URel k n j u u') : 𝓘 u = 𝓘 u' := by
  by_cases e : u = u'; · rw [e]
  have ndj := not_disjoint hu hu' huu'
  have n₁ := (hu.1.2 _ hu'.1.1).mt ndj
  rw [disjoint_comm] at ndj
  have n₂ := (hu'.1.2 _ hu.1.1).mt ndj
  simp_rw [URel, e, false_or, 𝔗₁, mem_setOf] at huu'; obtain ⟨p, ⟨_, _, sl₁⟩, sl₂⟩ := huu'
  rcases le_or_lt (𝔰 u) (𝔰 u') with h | h
  · exact eq_of_le_of_not_lt (Grid.le_dyadic h sl₁.1 sl₂.1) n₁
  · exact (eq_of_le_of_not_lt (Grid.le_dyadic h.le sl₂.1 sl₁.1) n₂).symm

/-- Helper for 5.4.2 that is also used in 5.4.9. -/
lemma urel_of_not_disjoint {x y : 𝔓 X} (my : y ∈ 𝔘₂ k n j) (xny : x ≠ y) (xye : 𝓘 x = 𝓘 y)
    (nd : ¬Disjoint (ball_(x) (𝒬 x) 100) (ball_(y) (𝒬 y) 100)) : URel k n j y x := by
  rw [not_disjoint_iff] at nd
  obtain ⟨(ϑ : Θ X), (ϑx : ϑ ∈ ball_{𝓘 x} (𝒬 x) 100), (ϑy : ϑ ∈ ball_{𝓘 y} (𝒬 y) 100)⟩ := nd
  rw [𝔘₂, mem_setOf, not_disjoint_iff] at my; obtain ⟨p, hp, _⟩ := my.2
  suffices w : ball_(x) (𝒬 x) 1 ⊆ ball_(y) (𝒬 y) 500 by
    right; use p, hp; obtain ⟨_, np, sl⟩ := hp
    have : smul 10 p ≤ smul 500 y := (smul_mono_left (by norm_num)).trans (wiggle_order_500 sl np)
    exact ⟨(xye ▸ sl.1 : 𝓘 p ≤ 𝓘 x), this.2.trans w⟩
  intro (q : Θ X) (mq : q ∈ ball_{𝓘 x} (𝒬 x) 1)
  rw [@mem_ball] at mq ⊢
  calc
    _ ≤ dist_(y) q ϑ + dist_(y) ϑ (𝒬 y) := dist_triangle ..
    _ ≤ dist_(y) q (𝒬 x) + dist_(y) ϑ (𝒬 x) + dist_(y) ϑ (𝒬 y) := by
      gcongr; apply dist_triangle_right
    _ < 1 + 100 + 100 := by
      gcongr
      · rwa [xye] at mq
      · rwa [@mem_ball, xye] at ϑx
      · rwa [@mem_ball] at ϑy
    _ < _ := by norm_num

/-- Lemma 5.4.2. -/
lemma equivalenceOn_urel : EquivalenceOn (URel (X := X) k n j) (𝔘₂ k n j) where
  refl _ _ := .rfl
  trans {x y z} mx my mz xy yz := by
    by_cases xny : x = y; · rwa [xny]
    have xye := URel.eq mx my xy
    have := URel.not_disjoint mx my xy
    rw [not_disjoint_iff] at this
    obtain ⟨(ϑ : Θ X), (ϑx : ϑ ∈ ball_{𝓘 x} (𝒬 x) 100), (ϑy : ϑ ∈ ball_{𝓘 y} (𝒬 y) 100)⟩ := this
    have yze := URel.eq my mz yz
    have := URel.not_disjoint my mz yz
    rw [not_disjoint_iff] at this
    obtain ⟨(θ : Θ X), (θy : θ ∈ ball_{𝓘 y} (𝒬 y) 100), (θz : θ ∈ ball_{𝓘 z} (𝒬 z) 100)⟩ := this
    simp_rw [URel, xny, false_or] at xy; obtain ⟨p, mp, sp⟩ := xy
    suffices ball_(z) (𝒬 z) 1 ⊆ ball_(x) (𝒬 x) 500 by
      right; use p, mp; obtain ⟨_, np, sl⟩ := mp
      have w : ball_(x) (𝒬 x) 500 ⊆ ball_(p) (𝒬 p) 4 := (wiggle_order_500 sl np).2
      exact ⟨(yze ▸ xye ▸ sl.1 : 𝓘 p ≤ 𝓘 z), (this.trans w).trans (ball_subset_ball (by norm_num))⟩
    intro (q : Θ X) (mq : q ∈ ball_{𝓘 z} (𝒬 z) 1)
    rw [@mem_ball] at mq ⊢
    calc
      _ ≤ dist_(x) q ϑ + dist_(x) ϑ (𝒬 x) := dist_triangle ..
      _ < dist_(x) q ϑ + 100 := by gcongr; rwa [@mem_ball] at ϑx
      _ ≤ dist_(x) q (𝒬 y) + dist_(x) ϑ (𝒬 y) + 100 := by gcongr; exact dist_triangle_right ..
      _ < dist_(x) q (𝒬 y) + 100 + 100 := by gcongr; rwa [@mem_ball, ← xye] at ϑy
      _ ≤ dist_(x) q θ + dist_(x) θ (𝒬 y) + 100 + 100 := by gcongr; exact dist_triangle ..
      _ < dist_(x) q θ + 100 + 100 + 100 := by gcongr; rwa [@mem_ball, ← xye] at θy
      _ ≤ dist_(x) q (𝒬 z) + dist_(x) θ (𝒬 z) + 100 + 100 + 100 := by
        gcongr; exact dist_triangle_right ..
      _ < 1 + 100 + 100 + 100 + 100 := by
        gcongr
        · rwa [← yze, ← xye] at mq
        · rwa [@mem_ball, ← yze, ← xye] at θz
      _ < _ := by norm_num
  symm {x y} mx my xy := by
    by_cases xny : x = y; · rw [xny]; exact .rfl
    exact urel_of_not_disjoint my xny (URel.eq mx my xy) (URel.not_disjoint mx my xy)

/-- `𝔘₃(k, n, j) ⊆ 𝔘₂ k n j` is an arbitary set of representatives of `URel` on `𝔘₂ k n j`,
given above (5.4.5). -/
def 𝔘₃ (k n j : ℕ) : Set (𝔓 X) :=
  (equivalenceOn_urel (k := k) (n := n) (j := j)).reprs

lemma 𝔘₃_subset_𝔘₂ : 𝔘₃ k n j ⊆ 𝔘₂ (X := X) k n j := EquivalenceOn.reprs_subset

/-- The subset `𝔗₂(u)` of `ℭ₆(k, n, j)`, given in (5.4.5).
In lemmas, we will assume `u ∈ 𝔘₃ k n l` -/
def 𝔗₂ (k n j : ℕ) (u : 𝔓 X) : Set (𝔓 X) :=
  ℭ₆ k n j ∩ ⋃ (u' ∈ 𝔘₂ k n j) (_ : URel k n j u u'), 𝔗₁ k n j u'

lemma 𝔗₂_subset_ℭ₆ : 𝔗₂ k n j u ⊆ ℭ₆ k n j := inter_subset_left ..

/-- Lemma 5.4.3 -/
lemma C6_forest : ℭ₆ (X := X) k n j = ⋃ u ∈ 𝔘₃ k n j, 𝔗₂ k n j u := by
  ext p; constructor <;> intro h
  · have : p ∈ ℭ₃ k n j := (ℭ₆_subset_ℭ₅ |>.trans ℭ₅_subset_ℭ₄ |>.trans ℭ₄_subset_ℭ₃) h
    rw [ℭ₃, mem_diff, 𝔏₂, mem_setOf] at this
    have mp := this.1
    simp_rw [this.1, true_and, not_not] at this
    obtain ⟨u, mu, np, sl⟩ := this
    have mp' : p ∈ 𝔗₁ k n j u := by
      rw [𝔗₁, mem_setOf]; exact ⟨ℭ₂_subset_ℭ₁ mp, np, sl⟩
    have mu' : u ∈ 𝔘₂ k n j := by
      rw [𝔘₂, mem_setOf]; exact ⟨mu, not_disjoint_iff.mpr ⟨_, mp', h⟩⟩
    let rr := equivalenceOn_urel (X := X) (k := k) (n := n) (j := j)
    rw [mem_iUnion₂]; use rr.out u, (rr.out_mem_reprs mu')
    refine ⟨h, ?_⟩; rw [mem_iUnion₂]; use u, mu'; rw [mem_iUnion]; use rr.out_rel mu'
  · rw [mem_iUnion₂] at h; obtain ⟨_, _, mp, _⟩ := h; exact mp

/- Lemma 5.4.4 seems to be a duplicate of Lemma 5.4.6.
The numberings below might change once we remove Lemma 5.4.4 -/

/-- Lemma 5.4.5, verifying (2.0.32) -/
lemma forest_geometry (hu : u ∈ 𝔘₃ k n j) (hp : p ∈ 𝔗₂ k n j u) : smul 4 p ≤ smul 1 u := by
  rw [𝔗₂, mem_inter_iff, mem_iUnion₂] at hp
  obtain ⟨_, u', mu', w⟩ := hp; rw [mem_iUnion] at w; obtain ⟨ru, mp'⟩ := w
  rw [𝔗₁, mem_setOf] at mp'; obtain ⟨_, np, sl⟩ := mp'
  have xye := URel.eq (EquivalenceOn.reprs_subset hu) mu' ru
  have := URel.not_disjoint (EquivalenceOn.reprs_subset hu) mu' ru
  rw [not_disjoint_iff] at this
  obtain ⟨(ϑ : Θ X), (ϑx : ϑ ∈ ball_{𝓘 u} (𝒬 u) 100), (ϑy : ϑ ∈ ball_{𝓘 u'} (𝒬 u') 100)⟩ := this
  suffices ball_(u) (𝒬 u) 1 ⊆ ball_(u') (𝒬 u') 500 by
    have w : smul 4 p ≤ smul 500 u' := (wiggle_order_500 sl np)
    exact ⟨(xye ▸ sl.1 : 𝓘 p ≤ 𝓘 u), w.2.trans this⟩
  intro (q : Θ X) (mq : q ∈ ball_{𝓘 u} (𝒬 u) 1)
  rw [@mem_ball] at mq ⊢
  calc
    _ ≤ dist_(u') q ϑ + dist_(u') ϑ (𝒬 u') := dist_triangle ..
    _ ≤ dist_(u') q (𝒬 u) + dist_(u') ϑ (𝒬 u) + dist_(u') ϑ (𝒬 u') := by
      gcongr; apply dist_triangle_right
    _ < 1 + 100 + 100 := by
      gcongr
      · rwa [xye] at mq
      · rwa [@mem_ball, xye] at ϑx
      · rwa [@mem_ball] at ϑy
    _ < _ := by norm_num

/-- Lemma 5.4.6, verifying (2.0.33) -/
lemma forest_convex : OrdConnected (𝔗₂ k n j u) := by
  rw [ordConnected_def]; intro p mp p'' mp'' p' mp'
  have mp'₅ : p' ∈ ℭ₅ (X := X) k n j :=
    (ordConnected_C5.out ((𝔗₂_subset_ℭ₆.trans ℭ₆_subset_ℭ₅) mp)
      ((𝔗₂_subset_ℭ₆.trans ℭ₆_subset_ℭ₅) mp'')) mp'
  have mp'₆ : p' ∈ ℭ₆ k n j := by
    have := 𝔗₂_subset_ℭ₆ mp; rw [ℭ₆, mem_setOf] at this ⊢
    refine ⟨mp'₅, ?_⟩; replace this := this.2; contrapose! this
    exact mp'.1.1.1.trans this
  simp_rw [𝔗₂, mem_inter_iff, mp'₆, true_and, mem_iUnion₂, mem_iUnion] at mp'' ⊢
  obtain ⟨u', mu', ru, _, np'', sl⟩ := mp''.2
  have pnu : 𝓘 p' < 𝓘 u' := (mp'.2.1).trans_lt (lt_of_le_of_ne sl.1 np'')
  use u', mu', ru; rw [𝔗₁, mem_setOf]
  use (ℭ₅_subset_ℭ₄ |>.trans ℭ₄_subset_ℭ₃ |>.trans ℭ₃_subset_ℭ₂ |>.trans ℭ₂_subset_ℭ₁) mp'₅, pnu.ne
  exact (wiggle_order_11_10 mp'.2 (C5_3_3_le (X := X).trans (by norm_num))).trans sl

/-- Lemma 5.4.7, verifying (2.0.36)
Note: swapped `u` and `u'` to match (2.0.36) -/
lemma forest_separation (hu : u ∈ 𝔘₃ k n j) (hu' : u' ∈ 𝔘₃ k n j) (huu' : u ≠ u')
    (hp : p ∈ 𝔗₂ k n j u') (h : 𝓘 p ≤ 𝓘 u) : 2 ^ (Z * (n + 1)) < dist_(p) (𝒬 p) (𝒬 u) := by
  simp_rw [𝔗₂, mem_inter_iff, mem_iUnion₂, mem_iUnion] at hp
  obtain ⟨mp₆, v, mv, rv, ⟨-, np, sl⟩⟩ := hp
  obtain ⟨p', mp', lp', sp'⟩ := exists_le_of_mem_ℭ₂ <|
    (ℭ₆_subset_ℭ₅ |>.trans ℭ₅_subset_ℭ₄ |>.trans ℭ₄_subset_ℭ₃ |>.trans ℭ₃_subset_ℭ₂) mp₆
  have np'u : ¬URel k n j v u := by
    by_contra h; apply absurd (Eq.symm _) huu'
    replace h := equivalenceOn_urel.trans (𝔘₃_subset_𝔘₂ hu') mv (𝔘₃_subset_𝔘₂ hu) rv h
    exact EquivalenceOn.reprs_inj hu' hu h
  have vnu : v ≠ u := by by_contra h; subst h; exact absurd URel.rfl np'u
  simp_rw [URel, vnu, false_or, not_exists, not_and] at np'u
  have mpt : p' ∈ 𝔗₁ k n j v := by
    refine ⟨mp', ?_, ?_⟩
    · exact (lp'.1.trans_lt (lt_of_le_of_ne sl.1 np)).ne
    · exact (wiggle_order_11_10 lp' (C5_3_3_le (X := X).trans (by norm_num))).trans sl
  specialize np'u p' mpt
  have 𝓘p'u : 𝓘 p' ≤ 𝓘 u := lp'.1.trans h
  simp_rw [TileLike.le_def, smul_fst, smul_snd, 𝓘p'u, true_and,
    not_subset_iff_exists_mem_not_mem] at np'u
  obtain ⟨(q : Θ X), mq, nq⟩ := np'u
  simp_rw [mem_ball, not_lt] at mq nq
  have d8 : 8 < dist_(p') (𝒬 p) (𝒬 u) :=
    calc
      _ = 10 - 1 - 1 := by norm_num
      _ < 10 - 1 - dist_(u) q (𝒬 u) := by gcongr
      _ ≤ 10 - 1 - dist_(p') q (𝒬 u) := tsub_le_tsub_left (Grid.dist_mono 𝓘p'u) _
      _ ≤ dist_(p') q (𝒬 p') - 1 - dist_(p') q (𝒬 u) := by gcongr
      _ < dist_(p') q (𝒬 p') - dist_(p') (𝒬 p) (𝒬 p') - dist_(p') q (𝒬 u) := by
        gcongr; rw [← @mem_ball]; exact subset_cball (lp'.2 𝒬_mem_Ω)
      _ ≤ _ := by
        rw [sub_le_iff_le_add', sub_le_iff_le_add]
        nth_rw 3 [dist_comm]; apply dist_triangle4
  have Znpos : 0 < Z * (n + 1) := by rw [defaultZ]; positivity
  let d : ℕ := (𝔰 p - 𝔰 p').toNat
  have sd : 𝔰 p' + d = 𝔰 p := by simp_rw [d]; rw [Int.toNat_sub_of_le] <;> omega
  have d1 : dist_(p') (𝒬 p) (𝒬 u) ≤ C2_1_2 a ^ d * dist_(p) (𝒬 p) (𝒬 u) :=
    Grid.dist_strictMono_iterate lp'.1 sd
  have Cdpos : 0 < C2_1_2 a ^ d := by rw [C2_1_2]; positivity
  have Cidpos : 0 < (C2_1_2 a)⁻¹ ^ d := by rw [C2_1_2]; positivity
  calc
    _ ≤ (C2_1_2 a)⁻¹ ^ (Z * (n + 1)) := by
      refine pow_le_pow_left zero_le_two ?_ _
      nth_rw 1 [C2_1_2, ← Real.inv_rpow zero_le_two, ← Real.rpow_neg_one,
        ← Real.rpow_mul zero_le_two, neg_one_mul, neg_mul, neg_neg, ← Real.rpow_one 2]
      apply Real.rpow_le_rpow_of_exponent_le one_le_two
      norm_cast; linarith [four_le_a X]
    _ ≤ (C2_1_2 a)⁻¹ ^ d := by
      refine pow_le_pow_right ?_ (by omega)
      simp_rw [one_le_inv_iff, C2_1_2_le_one (X := X), and_true, C2_1_2]; positivity
    _ ≤ (C2_1_2 a)⁻¹ ^ d * 8 := by nth_rw 1 [← mul_one (_ ^ d)]; gcongr; norm_num
    _ < (C2_1_2 a)⁻¹ ^ d * dist_(p') (𝒬 p) (𝒬 u) := by gcongr
    _ ≤ _ := by
      rwa [← mul_le_mul_iff_of_pos_left Cdpos, inv_pow, ← mul_assoc, mul_inv_cancel Cdpos.ne',
        one_mul]

/-- Lemma 5.4.8, verifying (2.0.37) -/
lemma forest_inner (hu : u ∈ 𝔘₃ k n j) (hp : p ∈ 𝔗₂ k n j u') :
    ball (𝔠 p) (8 * D ^ 𝔰 p) ⊆ 𝓘 u := by
  sorry

def C5_4_8 (n : ℕ) : ℕ := (4 * n + 12) * 2 ^ n

lemma exists_smul_le_of_𝔘₃ (u : 𝔘₃ k n j) : ∃ m : 𝔐 (X := X) k n, smul 100 u.1 ≤ smul 1 m.1 := by
  obtain ⟨u, mu⟩ := u
  replace mu := (𝔘₃_subset_𝔘₂.trans 𝔘₂_subset_𝔘₁ |>.trans 𝔘₁_subset_ℭ₁) mu
  rw [ℭ₁, mem_diff, preℭ₁, mem_setOf, filter_mem_univ_eq_toFinset] at mu
  replace mu := (show 0 < 2 ^ j by positivity).trans_le mu.1.2
  rw [Finset.card_pos] at mu; obtain ⟨m, hm⟩ := mu
  rw [mem_toFinset, 𝔅] at hm; exact ⟨⟨m, hm.1⟩, hm.2⟩

variable (k n j) in
def mf (u : 𝔘₃ (X := X) k n j) : 𝔐 (X := X) k n := (exists_smul_le_of_𝔘₃ u).choose

lemma mf_injOn : InjOn (mf k n j) {u | x ∈ 𝓘 u.1} := fun u mu u' mu' e ↦ by
  set m := mf k n j u
  have iu : smul 100 u.1 ≤ smul 1 m.1 := (exists_smul_le_of_𝔘₃ u).choose_spec
  have iu' : smul 100 u'.1 ≤ smul 1 m.1 := e ▸ (exists_smul_le_of_𝔘₃ u').choose_spec
  have su : ball_{𝓘 m.1} (𝒬 m.1) 1 ⊆ ball_{𝓘 u.1} (𝒬 u.1) 100 := iu.2
  have su' : ball_{𝓘 m.1} (𝒬 m.1) 1 ⊆ ball_{𝓘 u'.1} (𝒬 u'.1) 100 := iu'.2
  have nd : ¬Disjoint (ball_{𝓘 u.1} (𝒬 u.1) 100) (ball_{𝓘 u'.1} (𝒬 u'.1) 100) := by
    rw [not_disjoint_iff]
    use 𝒬 m.1, su (mem_ball_self zero_lt_one), su' (mem_ball_self zero_lt_one)
  by_contra! h; rw [← Subtype.coe_ne_coe] at h; apply absurd _ nd
  have nr : ¬URel k n j u.1 u'.1 := by contrapose! h; exact EquivalenceOn.reprs_inj u.2 u'.2 h
  have n𝓘 : 𝓘 u.1 ≠ 𝓘 u'.1 := by
    contrapose! nr; rw [disjoint_comm] at nd
    exact urel_of_not_disjoint (𝔘₃_subset_𝔘₂ u.2) h.symm nr.symm nd
  rcases le_or_lt (s (𝓘 u.1)) (s (𝓘 u'.1)) with hs | hs
  · have := lt_of_le_of_ne ((le_or_disjoint hs).resolve_right
      (not_disjoint_iff.mpr ⟨_, mu, mu'⟩)) n𝓘
    have u₁ := (𝔘₃_subset_𝔘₂.trans 𝔘₂_subset_𝔘₁) u.2
    exact u₁.2 u' ((𝔘₃_subset_𝔘₂.trans 𝔘₂_subset_𝔘₁ |>.trans 𝔘₁_subset_ℭ₁) u'.2) this
  · have := lt_of_le_of_ne ((le_or_disjoint hs.le).resolve_right
      (not_disjoint_iff.mpr ⟨_, mu', mu⟩)) n𝓘.symm
    have u'₁ := (𝔘₃_subset_𝔘₂.trans 𝔘₂_subset_𝔘₁) u'.2
    exact (u'₁.2 u ((𝔘₃_subset_𝔘₂.trans 𝔘₂_subset_𝔘₁ |>.trans 𝔘₁_subset_ℭ₁) u.2) this).symm

lemma stackSize_𝔘₃_le_𝔐 (x : X) : stackSize (𝔘₃ k n j) x ≤ stackSize (𝔐 k n) x := by
  let mf' : 𝔓 X → 𝔓 X := fun u ↦ if mu : u ∈ 𝔘₃ k n j then mf k n j ⟨u, mu⟩ else default
  simp_rw [stackSize, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id]
  refine Finset.card_le_card_of_injOn mf' (fun u mu ↦ ?_) (fun u mu u' mu' e ↦ ?_)
  · simp_rw [Finset.mem_filter, Finset.mem_univ, true_and] at mu ⊢
    simp_rw [mf', mu.1, dite_true]
    have : 𝓘 u ≤ 𝓘 (mf k n j ⟨u, mu.1⟩) := (exists_smul_le_of_𝔘₃ ⟨u, mu.1⟩).choose_spec.1
    exact ⟨(mf k n j ⟨u, mu.1⟩).2, this.1 mu.2⟩
  · simp_rw [Finset.coe_filter, mem_setOf, Finset.mem_filter, Finset.mem_univ, true_and] at mu mu'
    simp_rw [mf', mu.1, mu'.1, dite_true, Subtype.val_inj] at e
    simpa using mf_injOn mu.2 mu'.2 e

/-- Lemma 5.4.9, used to verify that 𝔘₄ satisfies 2.0.34. -/
lemma forest_stacking (x : X) (hkn : k < n) : stackSize (𝔘₃ (X := X) k n j) x ≤ C5_4_8 n := by
  by_contra! h
  let C : Finset (𝔓 X) := Finset.univ.filter fun u ↦ u ∈ 𝔘₃ (X := X) k n j ∧ x ∈ 𝓘 u
  have Cc : C.card = stackSize (𝔘₃ k n j) x := by
    simp_rw [stackSize, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id,
      C, Grid.mem_def, Finset.filter_filter]
  have Cn : C.Nonempty := by
    by_contra! Ce; rw [Finset.not_nonempty_iff_eq_empty] at Ce
    simp_rw [← Cc, Ce, Finset.card_empty, not_lt_zero'] at h
  let C' : Finset (Grid X) := C.image 𝓘
  have C'n : C'.Nonempty := by rwa [Finset.image_nonempty]
  obtain ⟨i, mi, li⟩ := C'.exists_minimal C'n
  simp_rw [C', Finset.mem_image, C, Finset.mem_filter, Finset.mem_univ, true_and] at mi
  obtain ⟨u, ⟨mu, mx⟩, uei⟩ := mi; subst uei
  have uA : (𝓘 u : Set X) ⊆ setA (2 * n + 6) k n := fun y my ↦
    calc
      _ = (4 * n + 12) * 2 ^ n := by ring
      _ < stackSize (𝔘₃ k n j) x := h
      _ ≤ stackSize (𝔘₃ k n j) y := by
        simp_rw [stackSize, indicator_apply, Pi.one_apply, Finset.sum_boole, Nat.cast_id]
        apply Finset.card_le_card fun v mv ↦ ?_
        simp_rw [Finset.mem_filter, Finset.mem_univ, true_and] at mv ⊢
        have mvC' : 𝓘 v ∈ C' := by
          simp_rw [C', Finset.mem_image]; use v
          simp_rw [C, Finset.mem_filter, Finset.mem_univ, true_and, and_true]; exact mv
        specialize li _ mvC'
        have inc := (or_assoc.mpr (le_or_ge_or_disjoint (i := 𝓘 u) (j := 𝓘 v))).resolve_right
          (not_disjoint_iff.mpr ⟨_, mx, mv.2⟩)
        simp_rw [le_iff_eq_or_lt] at inc
        replace inc : 𝓘 u = 𝓘 v ∨ 𝓘 u < 𝓘 v := by tauto
        rw [← le_iff_eq_or_lt] at inc
        exact ⟨mv.1, inc.1 my⟩
      _ ≤ _ := stackSize_𝔘₃_le_𝔐 _
  refine absurd (disjoint_left.mpr fun v mv ↦ ?_) (𝔘₃_subset_𝔘₂ mu).2
  rw [𝔗₁, mem_setOf] at mv; rw [ℭ₆, mem_setOf, not_and, not_not]
  refine fun _ ↦ (mv.2.2.1).1.trans ?_
  calc
    _ ⊆ setA (2 * n + 6) k n := uA
    _ ⊆ G₂ := subset_iUnion₂_of_subset n k (subset_iUnion_of_subset hkn subset_rfl)
    _ ⊆ _ := subset_union_of_subset_left subset_union_right G₃

/-- Pick a maximal subset of `s` satisfying `∀ x, stackSize s x ≤ 2 ^ n` -/
def aux𝔘₄ (s : Set (𝔓 X)) : Set (𝔓 X) := by
  revert s; sorry

/-- The sets `(𝔘₄(k, n, j, l))_l` form a partition of `𝔘₃ k n j`. -/
def 𝔘₄ (k n j l : ℕ) : Set (𝔓 X) :=
  aux𝔘₄ <| 𝔘₃ k n j \ ⋃ (l' < l), 𝔘₄ k n j l'

lemma iUnion_𝔘₄ : ⋃ l, 𝔘₄ (X := X) k n j l = 𝔘₃ k n j := by
  sorry

lemma 𝔘₄_subset_𝔘₃ : 𝔘₄ (X := X) k n j l ⊆ 𝔘₃ k n j := by
  sorry

lemma le_of_nonempty_𝔘₄ (h : (𝔘₄ (X := X) k n j l).Nonempty) : l < 4 * n + 13 := by
  sorry

lemma pairwiseDisjoint_𝔘₄ : univ.PairwiseDisjoint (𝔘₄ (X := X) k n j) := by
  sorry

lemma stackSize_𝔘₄_le (x : X) : stackSize (𝔘₄ (X := X) k n j l) x ≤ 2 ^ n := by
  sorry

open TileStructure
variable (k n j l) in
def forest : Forest X n where
  𝔘 := 𝔘₄ k n j l
  𝔗 := 𝔗₂ k n j
  nonempty {u} hu := sorry
  ordConnected {u} hu := forest_convex
  𝓘_ne_𝓘 hu hp := sorry
  smul_four_le {u} hu := forest_geometry <| 𝔘₄_subset_𝔘₃ hu
  stackSize_le {x} := stackSize_𝔘₄_le x
  dens₁_𝔗_le {u} hu := dens1_le <| 𝔗₂_subset_ℭ₆.trans ℭ₆_subset_ℭ
  lt_dist hu hu' huu' p hp := forest_separation (𝔘₄_subset_𝔘₃ hu) (𝔘₄_subset_𝔘₃ hu') huu' hp
  ball_subset hu p hp := forest_inner (𝔘₄_subset_𝔘₃ hu) hp

/-- The constant used in Lemma 5.1.2, with value `2 ^ (235 * a ^ 3) / (q - 1) ^ 4` -/
-- todo: redefine in terms of other constants
def C5_1_2 (a : ℝ) (q : ℝ≥0) : ℝ≥0 := 2 ^ (235 * a ^ 3) / (q - 1) ^ 4

lemma C5_1_2_pos : C5_1_2 a nnq > 0 := sorry

lemma forest_union {f : X → ℂ} (hf : ∀ x, ‖f x‖ ≤ F.indicator 1 x) :
  ∫⁻ x in G \ G', ‖∑ p ∈ Finset.univ.filter (· ∈ 𝔓₁), T p f x‖₊ ≤
    C5_1_2 a nnq * volume G ^ (1 - q⁻¹) * volume F ^ q⁻¹  := by
  sorry

/-! ## Section 5.5 and Lemma 5.1.3 -/

/-- The set 𝔓_{G\G'} in the blueprint -/
def 𝔓pos : Set (𝔓 X) := { p : 𝔓 X | 0 < volume (𝓘 p ∩ G ∩ G'ᶜ) }

/-- The union occurring in the statement of Lemma 5.5.1 containing 𝔏₀ -/
def ℜ₀ : Set (𝔓 X) := 𝔓pos ∩ ⋃ (n : ℕ) (k ≤ n), 𝔏₀ k n

/-- The union occurring in the statement of Lemma 5.5.1 containing 𝔏₁ -/
def ℜ₁ : Set (𝔓 X) := 𝔓pos ∩ ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3) (l ≤ Z * (n + 1)), 𝔏₁ k n j l

/-- The union occurring in the statement of Lemma 5.5.1 containing 𝔏₂ -/
def ℜ₂ : Set (𝔓 X) := 𝔓pos ∩ ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3), 𝔏₂ k n j

/-- The union occurring in the statement of Lemma 5.5.1 containing 𝔏₃ -/
def ℜ₃ : Set (𝔓 X) := 𝔓pos ∩ ⋃ (n : ℕ) (k ≤ n) (j ≤ 2 * n + 3) (l ≤ Z * (n + 1)), 𝔏₃ k n j l

/-- Lemma 5.5.1 -/
lemma antichain_decomposition : 𝔓pos (X := X) ∩ 𝔓₁ᶜ = ℜ₀ ∪ ℜ₁ ∪ ℜ₂ ∪ ℜ₃ := by
  sorry

/-- The subset `𝔏₀(k, n, l)` of `𝔏₀(k, n)`, given in Lemma 5.5.3.
  We use the name `𝔏₀'` in Lean. The indexing is off-by-one w.r.t. the blueprint -/
-- Note: this is basically the same construction as `𝔏₁`.
-- Please generalize this construction and prove properties
-- (antichainness, union, the fact that it stops after `n`
-- steps if there are no antichains of length `n + 1`)
-- in proper generality.
def 𝔏₀' (k n l : ℕ) : Set (𝔓 X) :=
  minimals (·≤·) (𝔏₀ k n \ ⋃ (l' < l), 𝔏₀' k n l')

/-- Part of Lemma 5.5.2 -/
lemma iUnion_L0' : ⋃ (l ≤ n), 𝔏₀' (X := X) k n l = 𝔏₀ k n :=
  sorry

/-- Part of Lemma 5.5.2 -/
lemma pairwiseDisjoint_L0' : univ.PairwiseDisjoint (𝔏₀' (X := X) k n) :=
  sorry

/-- Part of Lemma 5.5.2 -/
lemma antichain_L0' : IsAntichain (·≤·) (𝔏₀' (X := X) k n l) :=
  sorry

/-- Lemma 5.5.3 -/
lemma antichain_L2 : IsAntichain (·≤·) (𝔏₂ (X := X) k n j) :=
  sorry

/-- Part of Lemma 5.5.4 -/
lemma antichain_L1 : IsAntichain (·≤·) (𝔏₁ (X := X) k n j l) :=
  sorry

/-- Part of Lemma 5.5.4 -/
lemma antichain_L3 : IsAntichain (·≤·) (𝔏₃ (X := X) k n j l) :=
  sorry

/-- The constant used in Lemma 5.1.3, with value `2 ^ (210 * a ^ 3) / (q - 1) ^ 5` -/
-- todo: redefine in terms of other constants
def C5_1_3 (a : ℝ) (q : ℝ≥0) : ℝ≥0 := 2 ^ (210 * a ^ 3) / (q - 1) ^ 5

lemma C5_1_3_pos : C5_1_3 a nnq > 0 := sorry

lemma forest_complement {f : X → ℂ} (hf : ∀ x, ‖f x‖ ≤ F.indicator 1 x) :
  ∫⁻ x in G \ G', ‖∑ p ∈ Finset.univ.filter (· ∉ 𝔓₁), T p f x‖₊ ≤
    C5_1_2 a nnq * volume G ^ (1 - q⁻¹) * volume F ^ q⁻¹  := by
  sorry

/-! ## Proposition 2.0.2 -/

/-- The constant used in Proposition 2.0.2,
which has value `2 ^ (440 * a ^ 3) / (q - 1) ^ 5` in the blueprint. -/
def C2_0_2 (a : ℝ) (q : ℝ≥0) : ℝ≥0 := C5_1_2 a q + C5_1_3 a q

lemma C2_0_2_pos : C2_0_2 a nnq > 0 := sorry

variable (X) in
theorem discrete_carleson :
    ∃ G', MeasurableSet G' ∧ 2 * volume G' ≤ volume G ∧
    ∀ f : X → ℂ, Measurable f → (∀ x, ‖f x‖ ≤ F.indicator 1 x) →
    ∫⁻ x in G \ G', ‖∑ p, T p f x‖₊ ≤
    C2_0_2 a nnq * volume G ^ (1 - q⁻¹) * volume F ^ q⁻¹ := by sorry
