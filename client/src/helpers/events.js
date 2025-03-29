/* global BigInt */
import { hexToAscii } from "@dojoengine/utils";
import { components, translateName } from "./components.js";

function parseData(value, type) {
  switch (typeof type) {
    case 'string':
      return hexToAscii(value)
    case 'number':
      return parseInt(value)
    case 'boolean':
      return Boolean(parseInt(value))
    default:
      
      return value
  }
}

export function translateEvent(event) {
  const name = translateName(event.keys[1]);
  const data = event.data;

  const keysNumber = parseInt(data[0]);

  if (!components[name]) return;
  const component = components[name];

  let values = [...data.slice(1, 1 + keysNumber), ...data.slice(keysNumber + 2)];

  const parsedFields = Object.keys(component).reduce((acc, key, index) => {
    if (component[key] === 'array') {
      return { ...acc, [key]: values.splice(index + 1, parseInt(values[index])).map(x => parseInt(x)) }
    }

    if (component[key] === 'CreatureArray') {
      let creatureCount = parseInt(values[index]);
      let creatures = values.splice(index + 1, creatureCount * 3);

      return {
        ...acc, [key]: Array.from({ length: creatureCount }, (_, i) => ({
          cardIndex: parseInt(creatures[i * 3]),
          attack: parseInt(creatures[i * 3 + 1]),
          health: parseInt(creatures[i * 3 + 2]),
        }))
      }
    } else if (component[key] === 'Monster') {
      let monster = values.splice(index + 1, 2)

      return {
        ...acc, [key]: {
          monsterId: parseInt(values[index]),
          monsterAttack: parseInt(monster[0]),
          monsterHealth: parseInt(monster[1]),
        }
      }
    } else if (component[key] === 'Hero') {
      let hero = values.splice(index + 1, 1)

      return {
        ...acc, [key]: {
          heroHealth: parseInt(values[index]),
          heroEnergy: parseInt(hero[0]),
        }
      }
    } else if (component[key] === 'BattleEffects') {
      let battleEffects = values.splice(index + 1, 7)
      return {
        ...acc, [key]: {
          enemyMarks: parseInt(values[index]),
          heroDmgReduction: parseInt(battleEffects[0]),
          nextHunterAttackBonus: parseInt(battleEffects[1]),
          nextHunterHealthBonus: parseInt(battleEffects[2]),
          nextBruteAttackBonus: parseInt(battleEffects[3]),
          nextBruteHealthBonus: parseInt(battleEffects[4]),
          nextMagicalAttackBonus: parseInt(battleEffects[5]),
          nextMagicalHealthBonus: parseInt(battleEffects[6]),
        }
      }
    }

    return { ...acc, [key]: parseData(values[index], component[key]) }
  }, {})

  return {
    componentName: name,
    ...parsedFields
  }
}