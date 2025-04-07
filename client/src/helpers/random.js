import { LCG_PRIME, U128_MAX } from './constants';

export function getEntropy(blockHash) {
  let r = BigInt(blockHash) % U128_MAX;

  return r % LCG_PRIME;
}

export function LCG(entropy) {
  let a = BigInt(25214903917);
  let c = BigInt(11);
  let m = BigInt(LCG_PRIME);

  return Number((a * BigInt(entropy) + c) % m);
}

export function getRandomNumber(seed, max) {
  if (max === 0) {
    return 0;
  }

  return seed % max + 1;
}