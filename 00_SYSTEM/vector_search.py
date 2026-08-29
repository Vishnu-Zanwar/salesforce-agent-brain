#!/usr/bin/env python3
"""
vector_search.py - Local semantic search over H-AKOS PINCODE notes.

Complements brain.ps1's exact/keyword search (fast, deterministic, always
tried first) with fuzzy semantic matching for queries that don't share
exact keywords with a note's title - e.g. "screen freezing" finding a note
titled "UI hang", which the keyword index would miss entirely.

100% local and offline once the model is downloaded once - no API calls,
no network dependency, no per-query cost. Uses a brute-force cosine
similarity scan (fine at hundreds of notes; would need a real vector DB
only in the thousands+ range, which isn't where this repo is).

Usage:
    python 00_SYSTEM/vector_search.py build            (re)build the embedding index
    python 00_SYSTEM/vector_search.py query "<text>" [--top 5]
"""
import json
import os
import sys
import argparse

import numpy as np

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REGISTRY_PATH = os.path.join(REPO_ROOT, "00_SYSTEM", "pincode_registry.json")
INDEX_DIR = os.path.join(REPO_ROOT, "00_SYSTEM", "vector_index")
EMBEDDINGS_PATH = os.path.join(INDEX_DIR, "embeddings.npy")
META_PATH = os.path.join(INDEX_DIR, "meta.json")
MODEL_NAME = "all-MiniLM-L6-v2"  # small (~80MB), fast, well-tested for semantic search


def _load_model():
    from sentence_transformers import SentenceTransformer
    return SentenceTransformer(MODEL_NAME)


def _extract_text(file_path, max_chars=800):
    """Title + the first chunk of body content, used as the embedding input."""
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()[:max_chars]
    except FileNotFoundError:
        return None


def build():
    with open(REGISTRY_PATH, "r", encoding="utf-8-sig") as f:
        reg = json.load(f)

    codes, texts, meta = [], [], []
    for prefix, data in reg["registry"].items():
        for code, entry in data.get("assigned", {}).items():
            file_path = os.path.join(REPO_ROOT, entry["file"].replace("\\", "/"))
            text = _extract_text(file_path)
            if text is None:
                print(f"SKIP {code}: file not found ({entry['file']})")
                continue
            codes.append(code)
            texts.append(f"{entry['title']}\n\n{text}")
            meta.append({"code": code, "title": entry["title"], "file": entry["file"]})

    if not texts:
        print("Nothing to embed - no registered PINCODEs with existing files.")
        return

    print(f"Embedding {len(texts)} note(s) with {MODEL_NAME}...")
    model = _load_model()
    embeddings = model.encode(texts, normalize_embeddings=True, show_progress_bar=True)

    os.makedirs(INDEX_DIR, exist_ok=True)
    np.save(EMBEDDINGS_PATH, embeddings.astype(np.float32))
    with open(META_PATH, "w", encoding="utf-8") as f:
        json.dump({"model": MODEL_NAME, "codes": codes, "meta": meta}, f, indent=2)

    print(f"Wrote {EMBEDDINGS_PATH} and {META_PATH}")


def query(text, top=5):
    if not os.path.exists(EMBEDDINGS_PATH) or not os.path.exists(META_PATH):
        print("NO_INDEX: run 'python 00_SYSTEM/vector_search.py build' first.")
        return

    with open(META_PATH, "r", encoding="utf-8") as f:
        meta_data = json.load(f)

    embeddings = np.load(EMBEDDINGS_PATH)
    model = _load_model()
    q_emb = model.encode([text], normalize_embeddings=True)[0]

    # Cosine similarity == plain dot product since both sides are normalized.
    scores = embeddings @ q_emb
    ranked = np.argsort(-scores)[:top]

    print(f"Semantic search results for '{text}':")
    for idx in ranked:
        m = meta_data["meta"][idx]
        print(f"   #{m['code']}  [similarity {scores[idx]:.3f}]  {m['title']}")
        print(f"        {m['file']}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("build")
    q = sub.add_parser("query")
    q.add_argument("text")
    q.add_argument("--top", type=int, default=5)
    args = parser.parse_args()

    if args.command == "build":
        build()
    elif args.command == "query":
        query(args.text, args.top)


if __name__ == "__main__":
    main()
