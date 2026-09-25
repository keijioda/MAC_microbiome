#!/usr/bin/env python3
"""Reproduce the ZeeviD empirical-distribution interaction-power simulation.

Requires Python 3, NumPy, and SciPy. The 900 standardized ZeeviD capacity scores and the 
257 observed ETI-SR total scores are embedded below, so no external data file is needed.
"""

import base64
import json
import sys
import time
import zlib

import numpy as np
import scipy
from scipy.stats import norm
from scipy.stats import t as t_dist


# Reproducibility & design settings. Scenario-specific streams use BASE_SEED + offset.
BASE_SEED            = 20260921
REPLICATES           = 20_000
ALPHA                = 0.05
REDUCED_MODEL_R2     = 0.20
N_COVARIATES         = 6
TARGET_F2            = 0.029
N_PRIMARY            = 328
N_SENSITIVITY_GRID   = (300, 270)
DELTA_R2_CHECKPOINTS = (0.023, 0.028)

# Gaussian-copula correlation grid (Spearman-scale inputs).
# Copula variable order throughout: [eti, capacity, fiber, age].
RHO_ETI_CAPACITY_GRID   = (-0.15, 0.0, 0.15)
RHO_CAPACITY_FIBER_GRID = (0.0, 0.20, 0.40)
RHO_CAPACITY_AGE        = 0.043 
RHO_ETI_FIBER           = 0.0  
RHO_ETI_AGE             = 0.0  
RHO_FIBER_AGE           = 0.0  


# zlib-compressed, base64-encoded little-endian float64 vector (n = 900).
EMPIRICAL_SCORE_B64 = """
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
"""


# zlib-compressed, base64-encoded little-endian float64 vector (n = 257).
# The 257 observed ETI_Total_Score values
EMPIRICAL_ETI_B64 = """
eNqNlU1qxTAMhL30UossvMjCmMcjhFLy6AGq+5+mRyi0ViFfNKTeCPlnPBrJcik/w39NnTb8Dr9Nu2P/12c5jdgX48F9nlvDvnX6
T8xvwK/g08HTsG44H7hjzr/52Y918n+An+Iffhe8yWMF3jLt4ef1GIfn+IFnd/ko53tYB8zz+Gc+yXMI/HcR7yJ4Uucq7qsifwv2
ETdwNuhKnLAN9dJFPZjnOuyCN/NGv4l6tZv8Ds91uOgjeBSc38R9Q7wjE3WheBCX8RCne96H2MeIy7yunr8L1Zc4OP/CuSrqjfor
vKfn71/p3Tzvnxd88GP8VdzTPK8z6s280Y84XqKf3OWXcSs9q6if9UafD+RRvcdLfyz5vxB29/x9mfr/RN83EecBXf/i9G8MUGwh
"""


def load_empirical_scores():
    encoded = "".join(EMPIRICAL_SCORE_B64.split())
    scores = np.frombuffer(
        zlib.decompress(base64.b64decode(encoded)), dtype="<f8"
    ).copy()
    if scores.size != 900:
        raise RuntimeError(f"Expected 900 embedded scores; decoded {scores.size}.")
    return scores


def load_empirical_eti():
    encoded = "".join(EMPIRICAL_ETI_B64.split())
    values = np.frombuffer(
        zlib.decompress(base64.b64decode(encoded)), dtype="<f8"
    ).copy()
    if values.size != 257:
        raise RuntimeError(f"Expected 257 embedded ETI-SR scores; decoded {values.size}.")
    return values


def standardize(x):
    return (x - x.mean()) / x.std(ddof=1)


def spearman_to_pearson(rho_spearman):
    return 2.0 * np.sin(np.pi * rho_spearman / 6.0)


def build_copula_cholesky(rho_eti_capacity, rho_capacity_fiber):
    """4x4 Spearman-scale correlation matrix over [eti, capacity, fiber,
    age], converted to the Pearson/normal-scale matrix used to draw the
    latent Z, then Cholesky-factored. Raises if not positive definite."""
    spearman = np.array(
        [
            [1.0, rho_eti_capacity, RHO_ETI_FIBER, RHO_ETI_AGE],
            [rho_eti_capacity, 1.0, rho_capacity_fiber, RHO_CAPACITY_AGE],
            [RHO_ETI_FIBER, rho_capacity_fiber, 1.0, RHO_FIBER_AGE],
            [RHO_ETI_AGE, RHO_CAPACITY_AGE, RHO_FIBER_AGE, 1.0],
        ]
    )
    pearson = spearman_to_pearson(spearman)
    np.fill_diagonal(pearson, 1.0)
    try:
        return np.linalg.cholesky(pearson)
    except np.linalg.LinAlgError as exc:
        raise RuntimeError(
            "Copula correlation matrix is not positive definite for "
            f"rho_eti_capacity={rho_eti_capacity}, "
            f"rho_capacity_fiber={rho_capacity_fiber}:\n{pearson}"
        ) from exc


def draw_correlated_predictors(rng, capacity_pool, eti_pool, cholesky_factor, n):
    z = (cholesky_factor @ rng.normal(size=(4, n))).T 
    u = norm.cdf(z)
    eti = np.quantile(eti_pool, u[:, 0])
    capacity = np.quantile(capacity_pool, u[:, 1])
    fiber = z[:, 2]
    age = z[:, 3]
    return (
        standardize(eti),
        standardize(capacity),
        standardize(fiber),
        standardize(age),
    )


def _fit_hc3_test(x_full, outcome, n):
    xtx_inverse = np.linalg.inv(x_full.T @ x_full)
    beta = xtx_inverse @ x_full.T @ outcome
    residual = outcome - x_full @ beta
    residual_df = n - x_full.shape[1]

    leverage = np.sum((x_full @ xtx_inverse) * x_full, axis=1)
    adjusted_residual = residual / (1.0 - leverage)
    meat = x_full.T @ (x_full * adjusted_residual[:, None] ** 2)
    hc3_covariance = xtx_inverse @ meat @ xtx_inverse
    hc3_se = np.sqrt(hc3_covariance[-1, -1])
    hc3_t = beta[-1] / hc3_se
    hc3_p = 2.0 * t_dist.sf(abs(hc3_t), residual_df)
    significant = hc3_p < ALPHA

    ss_tot = np.sum((outcome - outcome.mean()) ** 2)
    x_reduced = x_full[:, :-1]
    beta_reduced = np.linalg.lstsq(x_reduced, outcome, rcond=None)[0]
    ss_res_reduced = np.sum((outcome - x_reduced @ beta_reduced) ** 2)
    r2_reduced_realized = 1.0 - ss_res_reduced / ss_tot
    ss_res_full = np.sum(residual**2)
    r2_full_realized = 1.0 - ss_res_full / ss_tot
    f2_realized = (r2_full_realized - r2_reduced_realized) / (1.0 - r2_full_realized)

    return significant, r2_reduced_realized, f2_realized


def _simulate_from_predictors(rng, reduced_predictors, interaction, f2, n):
    reduced_signal_variance = (
        REDUCED_MODEL_R2 * (1.0 + f2) / (1.0 - REDUCED_MODEL_R2)
    )
    n_predictors = reduced_predictors.shape[1]  # eti + capacity + covariates
    weights = np.array([0.40, 0.28] + [0.12] * (n_predictors - 2))
    signal = standardize(reduced_predictors @ weights) * np.sqrt(
        reduced_signal_variance
    )
    outcome = signal + np.sqrt(f2) * interaction + rng.normal(size=n)

    x_reduced = np.column_stack([np.ones(n), reduced_predictors])
    x_full = np.column_stack([x_reduced, interaction])
    return _fit_hc3_test(x_full, outcome, n)


def one_simulation(rng, capacity_pool, mode, f2, n):
    if mode == "normal":
        capacity = rng.normal(size=n)
    else:
        capacity = rng.choice(capacity_pool, size=n, replace=True)
    capacity = standardize(capacity)
    eti = standardize(rng.normal(size=n))

    covariates = rng.normal(size=(n, N_COVARIATES))
    covariates = (covariates - covariates.mean(axis=0)) / covariates.std(
        axis=0, ddof=1
    )
    reduced_predictors = np.column_stack([eti, capacity, covariates])
    interaction = eti * capacity

    return _simulate_from_predictors(rng, reduced_predictors, interaction, f2, n)


def one_simulation_correlated(rng, capacity_pool, eti_pool, cholesky_factor, f2, n):
    eti, capacity, fiber, age = draw_correlated_predictors(
        rng, capacity_pool, eti_pool, cholesky_factor, n
    )

    n_independent_covariates = N_COVARIATES - 2
    other_covariates = rng.normal(size=(n, n_independent_covariates))
    other_covariates = (
        other_covariates - other_covariates.mean(axis=0)
    ) / other_covariates.std(axis=0, ddof=1)

    reduced_predictors = np.column_stack(
        [eti, capacity, fiber, age, other_covariates]
    )
    interaction = eti * capacity

    return _simulate_from_predictors(rng, reduced_predictors, interaction, f2, n)


def run_scenario(capacity_pool, mode, f2, n, seed_offset):
    seed = BASE_SEED + seed_offset
    rng = np.random.default_rng(seed)
    significant_count = 0
    r2_reduced_sum = 0.0
    f2_sum = 0.0
    for _ in range(REPLICATES):
        significant, r2_reduced_realized, f2_realized = one_simulation(
            rng, capacity_pool, mode, f2, n
        )
        significant_count += significant
        r2_reduced_sum += r2_reduced_realized
        f2_sum += f2_realized
    power = significant_count / REPLICATES
    mcse = np.sqrt(power * (1.0 - power) / REPLICATES)
    return {
        "n": n,
        "mode": mode,
        "f2": f2,
        "seed": seed,
        "replicates": REPLICATES,
        "power_hc3": power,
        "mcse": float(mcse),
        "mean_realized_r2_reduced": r2_reduced_sum / REPLICATES,
        "mean_realized_f2": f2_sum / REPLICATES,
    }


def run_correlated_scenario(
    capacity_pool, eti_pool, rho_eti_capacity, rho_capacity_fiber, f2, n, seed_offset
):
    seed = BASE_SEED + seed_offset
    rng = np.random.default_rng(seed)
    cholesky_factor = build_copula_cholesky(rho_eti_capacity, rho_capacity_fiber)
    significant_count = 0
    r2_reduced_sum = 0.0
    f2_sum = 0.0
    for _ in range(REPLICATES):
        significant, r2_reduced_realized, f2_realized = one_simulation_correlated(
            rng, capacity_pool, eti_pool, cholesky_factor, f2, n
        )
        significant_count += significant
        r2_reduced_sum += r2_reduced_realized
        f2_sum += f2_realized
    power = significant_count / REPLICATES
    mcse = np.sqrt(power * (1.0 - power) / REPLICATES)
    return {
        "n": n,
        "rho_eti_capacity": rho_eti_capacity,
        "rho_capacity_fiber": rho_capacity_fiber,
        "rho_capacity_age": RHO_CAPACITY_AGE,
        "f2": f2,
        "seed": seed,
        "replicates": REPLICATES,
        "power_hc3": power,
        "mcse": float(mcse),
        "mean_realized_r2_reduced": r2_reduced_sum / REPLICATES,
        "mean_realized_f2": f2_sum / REPLICATES,
    }


def delta_r2_from_f2(f2):
    # f^2 = delta_R2 / (1 - R2_full), with R2_full = R2_reduced + delta_R2.
    return f2 * (1.0 - REDUCED_MODEL_R2) / (1.0 + f2)


def f2_from_delta_r2(delta_r2):
    # Inverse of delta_r2_from_f2: solve delta_r2 = f2*(1-R2_reduced)/(1+f2) for f2.
    return delta_r2 / ((1.0 - REDUCED_MODEL_R2) - delta_r2)

def _log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def main():
    t_start = time.time()
    
    scores = load_empirical_scores()
    eti_scores = load_empirical_eti()
    q01, q99 = np.quantile(scores, [0.01, 0.99])
    winsorized = np.clip(scores, q01, q99)

    scenarios = (
        ("empirical", scores, 0),
        ("winsorized_1_99", winsorized, 1),
        ("normal", scores, 2),
    )
    
    n_uncorrelated = len(scenarios) * (1 + len(N_SENSITIVITY_GRID))
    n_correlated = (
        len(RHO_ETI_CAPACITY_GRID)
        * len(RHO_CAPACITY_FIBER_GRID)
        * (1 + len(N_SENSITIVITY_GRID))
    )
    total_scenarios = n_uncorrelated + n_correlated
    scenario_counter = 0

    def run_logged(label, fn, *args):
        nonlocal scenario_counter
        scenario_counter += 1
        _log(f"[{scenario_counter}/{total_scenarios}] running  {label} ...")
        t0 = time.time()
        result = fn(*args)
        elapsed = time.time() - t0
        _log(
            f"[{scenario_counter}/{total_scenarios}] finished {label} "
            f"in {elapsed:.1f}s  (power={result['power_hc3'] * 100:.1f}%)"
        )
        return result

    _log(
        f"Starting: {total_scenarios} scenarios "
        f"({REPLICATES:,} replicates each, HC3 SEs)"
    )

    # Primary result: N = 328, uncorrelated
    primary_n328 = [
        run_logged(
            f"uncorrelated  N={N_PRIMARY}  mode={mode}",
            run_scenario, pool, mode, TARGET_F2, N_PRIMARY, offset,
        )
        for mode, pool, offset in scenarios
    ]

    # Sensitivity: accrual-shortfall contingencies (N=300, N=270),
    sensitivity_grid = []
    offset = 10
    for n in N_SENSITIVITY_GRID:
        for mode, pool, _ in scenarios:
            sensitivity_grid.append(
                run_logged(
                    f"uncorrelated  N={n}  mode={mode}",
                    run_scenario, pool, mode, TARGET_F2, n, offset,
                )
            )
            offset += 1

    # Sanity-check closed-form scaling estimate
    # delta_r2_checkpoints_n328 = []
    # offset = 20
    # for delta_r2 in DELTA_R2_CHECKPOINTS:
    #     f2 = f2_from_delta_r2(delta_r2)
    #     result = run_scenario(scores, "empirical", f2, N_PRIMARY, offset)
    #     result["delta_r2_target"] = delta_r2
    #     delta_r2_checkpoints_n328.append(result)
    #     offset += 1

    # Correlation grid at N=328, empirical
    correlated_grid_n328 = []
    offset = 30
    for rho_eti_capacity in RHO_ETI_CAPACITY_GRID:
        for rho_capacity_fiber in RHO_CAPACITY_FIBER_GRID:
            correlated_grid_n328.append(
                run_logged(
                    f"correlated    N={N_PRIMARY}  "
                    f"rho_eti_cap={rho_eti_capacity:+.2f}  "
                    f"rho_cap_fiber={rho_capacity_fiber:.2f}",
                    run_correlated_scenario,
                    scores,
                    eti_scores,
                    rho_eti_capacity,
                    rho_capacity_fiber,
                    TARGET_F2,
                    N_PRIMARY,
                    offset,
                )
            )
            offset += 1
            
    correlated_grid_sensitivity = []
    offset = 40
    for n in N_SENSITIVITY_GRID:
        for rho_eti_capacity in RHO_ETI_CAPACITY_GRID:
            for rho_capacity_fiber in RHO_CAPACITY_FIBER_GRID:
                correlated_grid_sensitivity.append(
                    run_logged(
                        f"correlated    N={n}  "
                        f"rho_eti_cap={rho_eti_capacity:+.2f}  "
                        f"rho_cap_fiber={rho_capacity_fiber:.2f}",
                        run_correlated_scenario,
                        scores,
                        eti_scores,
                        rho_eti_capacity,
                        rho_capacity_fiber,
                        TARGET_F2,
                        n,
                        offset,
                    )
                )
                offset += 1

    _log(f"All {total_scenarios} scenarios complete in {time.time() - t_start:.1f}s total")

    output = {
        "software": {
            "numpy": np.__version__,
            "scipy": scipy.__version__,
        },
        "design": {
            "base_seed": BASE_SEED,
            "replicates": REPLICATES,
            "two_sided_alpha": ALPHA,
            "reduced_model_r2": REDUCED_MODEL_R2,
            "n_covariates": N_COVARIATES,
            "n_primary": N_PRIMARY,
            "empirical_score_count": int(scores.size),
            "empirical_eti_count": int(eti_scores.size),
            "hc_covariance": "HC3",
            "rho_capacity_age_anchored": RHO_CAPACITY_AGE,
        },
        "uncorrelated_grid": primary_n328 + sensitivity_grid,
        "correlated_grid": correlated_grid_n328 + correlated_grid_sensitivity,
    }
    print(json.dumps(output, indent=2))
    
    with open("full_run_v3_output.json", "w") as f:
      json.dump(output, f, indent=2)


if __name__ == "__main__":
    main()
