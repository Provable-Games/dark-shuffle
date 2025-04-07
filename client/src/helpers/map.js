import { BEAST_NAME_PREFIXES, BEAST_NAME_SUFFIXES, get_monster_details } from "../battle/monsterUtils";
import { LCG, getRandomNumber } from "./random";

export const generateMapNodes = (mapLevel, mapSeed, settings) => {
    let nodes = []
    let nodeId = 1

    // depth 1
    nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, null, [], settings))

    if (settings.level_depth === 1) {
        return nodes;
    }

    let seed = LCG(mapSeed)
    let sections = getRandomNumber(seed, settings.possible_branches)
    let lastSectionNodeIds = []

    for (let i = 0; i < sections; i++) {
        if (settings.level_depth === 2) {
            lastSectionNodeIds.push(nodeId)
            continue;
        }

        // depth 2
        nodeId += 1
        nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [1], settings))

        if (settings.level_depth === 3) {
            lastSectionNodeIds.push(nodeId)
            continue;
        }

        // depth 3
        let depth3Count = 1
        nodeId += 1
        nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [nodeId - 1], settings))

        seed = LCG(seed)
        if (getRandomNumber(seed, settings.possible_branches) > 1) {
            depth3Count += 1
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [nodeId - 2], settings))
        }

        if (settings.level_depth === 4) {
            lastSectionNodeIds.push(nodeId)
            if (depth3Count > 1) {
                lastSectionNodeIds.push(nodeId - 1)
            }
            continue;
        }

        // depth 4
        seed = LCG(seed)
        if (getRandomNumber(seed, settings.possible_branches) > 1) {
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, depth3Count > 1 ? [nodeId - 2] : [nodeId - 1], settings))
            lastSectionNodeIds.push(nodeId)
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [nodeId - 2], settings))
            lastSectionNodeIds.push(nodeId)
        } else {
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, depth3Count > 1 ? [nodeId - 1, nodeId - 2] : [nodeId - 1], settings))
            lastSectionNodeIds.push(nodeId)
        }
    }

    // depth 5
    nodeId += 1
    nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, null, lastSectionNodeIds, settings))

    return nodes
}

export const getMonsterNode = (mapLevel, mapSeed, nodeId, section, parents, settings) => {
    let seed = mapSeed
    for (let i = 0; i < nodeId; i++) {
        seed = LCG(seed)
    }

    let monsterRange = 0;

    if (mapLevel < 5) {
        monsterRange = 75 - (15 * mapLevel);
    }

    let monsterId = getRandomNumber(seed, 75 - monsterRange) + monsterRange;
    let details = get_monster_details(monsterId);

    seed = LCG(seed)
    let attack = getRandomNumber(seed, settings.enemy_attack_max - settings.enemy_attack_min) + settings.enemy_attack_min;
    attack += (mapLevel - 1) * settings.enemy_attack_scaling;

    seed = LCG(seed)
    let health = getRandomNumber(seed, settings.enemy_health_max - settings.enemy_health_min) + settings.enemy_health_min;
    health += (mapLevel - 1) * settings.enemy_health_scaling;

    let monsterNameSeed = LCG(seed)
    let monsterPrefix = BEAST_NAME_PREFIXES[getRandomNumber(monsterNameSeed, 69)]
    let monsterSuffixSeed = LCG(monsterNameSeed)
    let monsterSuffix = BEAST_NAME_SUFFIXES[getRandomNumber(monsterSuffixSeed, 18)]
    let monsterName = `"${monsterPrefix} ${monsterSuffix}" ${details.name}`

    return {
        nodeId,
        monsterId,
        monsterName,
        status: 0,
        active: nodeId === 1,
        attack,
        health,
        monsterType: details.monsterType,
        nodeType: 'monster',
        section,
        parents: parents.sort()
    };
}