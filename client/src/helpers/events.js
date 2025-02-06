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

    if (component[key] === 'Creature') {
      let creature = values.splice(index + 1, 2)

      return {
        ...acc, [key]: {
          cardId: parseInt(values[index]),
          attack: parseInt(creature[0]),
          health: parseInt(creature[1]),
        }
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
      let hero = values.splice(index + 1, 2)

      return {
        ...acc, [key]: {
          heroHealth: parseInt(values[index]),
          heroMaxHealth: parseInt(hero[0]),
          heroEnergy: parseInt(hero[1]),
        }
      }
    } else if (component[key] === 'BattleEffects') {
      let battleEffects = values.splice(index + 1, 5)

      return {
        ...acc, [key]: {
          enemyMarks: parseInt(values[index]),
          heroDmgReduction: parseInt(battleEffects[0]),
          nextHunterAttackBonus: parseInt(battleEffects[1]),
          nextHunterHealthBonus: parseInt(battleEffects[2]),
          nextBruteAttackBonus: parseInt(battleEffects[3]),
          nextBruteHealthBonus: parseInt(battleEffects[4]),
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