import { BEAST_NAME_PREFIXES, BEAST_NAME_SUFFIXES, get_monster_details } from "../battle/monsterUtils";
import { LCG, getRandomNumber } from "./random";

export const generateMapNodes = (mapLevel, mapSeed) => {
    let nodes = []
    let nodeId = 1

    // depth 1
    nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, null, []))

    let seed = LCG(mapSeed)
    let sections = getRandomNumber(seed, 3)
    let lastSectionNodeIds = []

    for (let i = 0; i < sections; i++) {
        // depth 2
        nodeId += 1
        nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [1]))

        // depth 3
        let depth3Count = 1
        nodeId += 1
        nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [nodeId - 1]))

        seed = LCG(seed)
        if (getRandomNumber(seed, 2) > 1) {
            depth3Count += 1
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [nodeId - 2]))
        }

        // depth 4
        seed = LCG(seed)
        if (getRandomNumber(seed, 2) > 1) {
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, depth3Count > 1 ? [nodeId - 2] : [nodeId - 1]))
            lastSectionNodeIds.push(nodeId)
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, [nodeId - 2]))
            lastSectionNodeIds.push(nodeId)
        } else {
            nodeId += 1
            nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, i, depth3Count > 1 ? [nodeId - 1, nodeId - 2] : [nodeId - 1]))
            lastSectionNodeIds.push(nodeId)
        }
    }

    // depth 5
    nodeId += 1
    nodes.push(getMonsterNode(mapLevel, mapSeed, nodeId, null, lastSectionNodeIds))

    return nodes
}

export const getMonsterNode = (mapLevel, mapSeed, nodeId, section, parents) => {
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

    let health = 35 + (mapLevel * 5);
    let attack = (mapLevel + 1);

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