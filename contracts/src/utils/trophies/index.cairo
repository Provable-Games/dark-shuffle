use achievement::types::task::Task as BushidoTask;
use darkshuffle::utils::trophies;

pub const TROPHY_COUNT: u8 = 28;

#[derive(Copy, Drop)]
enum Trophy {
    None,
    BigHit,
    BruteForceI,
    BruteForceII,
    BruteForceIII,
    BruteSquadI,
    BruteSquadII,
    BruteSquadIII,
    ExplorerI,
    ExplorerII,
    ExplorerIII,
    Heroic,
    HuntersGatheringI,
    HuntersGatheringII,
    HuntersGatheringIII,
    HuntersProwessI,
    HuntersProwessII,
    HuntersProwessIII,
    Legend,
    MagicalAssemblyI,
    MagicalAssemblyII,
    MagicalAssemblyIII,
    MagicalMayhemI,
    MagicalMayhemII,
    MagicalMayhemIII,
    SeasonedI,
    SeasonedII,
    SeasonedIII,
    Survivor,
}

#[generate_trait]
impl TrophyImpl of TrophyTrait {
    #[inline]
    fn identifier(self: Trophy) -> felt252 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => trophies::BigHit::BigHit::identifier(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::identifier(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::identifier(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::identifier(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::identifier(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::identifier(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::identifier(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::identifier(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::identifier(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::identifier(2),
            Trophy::Heroic => trophies::Heroic::Heroic::identifier(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::identifier(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::identifier(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::identifier(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::identifier(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::identifier(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::identifier(2),
            Trophy::Legend => trophies::Legend::Legend::identifier(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::identifier(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::identifier(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::identifier(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::identifier(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::identifier(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::identifier(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::identifier(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::identifier(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::identifier(2),
            Trophy::Survivor => trophies::Survivor::Survivor::identifier(0),
        }
    }

    #[inline]
    fn hidden(self: Trophy) -> bool {
        match self {
            Trophy::None => true,
            Trophy::BigHit => trophies::BigHit::BigHit::hidden(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::hidden(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::hidden(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::hidden(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::hidden(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::hidden(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::hidden(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::hidden(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::hidden(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::hidden(2),
            Trophy::Heroic => trophies::Heroic::Heroic::hidden(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::hidden(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::hidden(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::hidden(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::hidden(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::hidden(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::hidden(2),
            Trophy::Legend => trophies::Legend::Legend::hidden(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::hidden(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::hidden(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::hidden(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::hidden(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::hidden(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::hidden(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::hidden(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::hidden(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::hidden(2),
            Trophy::Survivor => trophies::Survivor::Survivor::hidden(0),
        }
    }

    #[inline]
    fn index(self: Trophy) -> u8 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => trophies::BigHit::BigHit::index(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::index(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::index(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::index(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::index(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::index(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::index(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::index(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::index(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::index(2),
            Trophy::Heroic => trophies::Heroic::Heroic::index(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::index(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::index(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::index(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::index(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::index(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::index(2),
            Trophy::Legend => trophies::Legend::Legend::index(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::index(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::index(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::index(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::index(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::index(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::index(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::index(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::index(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::index(2),
            Trophy::Survivor => trophies::Survivor::Survivor::index(0),
        }
    }

    #[inline]
    fn points(self: Trophy) -> u16 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => trophies::BigHit::BigHit::points(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::points(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::points(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::points(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::points(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::points(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::points(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::points(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::points(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::points(2),
            Trophy::Heroic => trophies::Heroic::Heroic::points(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::points(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::points(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::points(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::points(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::points(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::points(2),
            Trophy::Legend => trophies::Legend::Legend::points(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::points(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::points(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::points(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::points(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::points(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::points(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::points(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::points(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::points(2),
            Trophy::Survivor => trophies::Survivor::Survivor::points(0),
        }
    }

    #[inline]
    fn group(self: Trophy) -> felt252 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => trophies::BigHit::BigHit::group(),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::group(),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::group(),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::group(),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::group(),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::group(),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::group(),
            Trophy::ExplorerI => trophies::Explorer::Explorer::group(),
            Trophy::ExplorerII => trophies::Explorer::Explorer::group(),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::group(),
            Trophy::Heroic => trophies::Heroic::Heroic::group(),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::group(),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::group(),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::group(),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::group(),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::group(),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::group(),
            Trophy::Legend => trophies::Legend::Legend::group(),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::group(),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::group(),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::group(),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::group(),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::group(),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::group(),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::group(),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::group(),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::group(),
            Trophy::Survivor => trophies::Survivor::Survivor::group(),
        }
    }

    #[inline]
    fn icon(self: Trophy) -> felt252 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => trophies::BigHit::BigHit::icon(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::icon(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::icon(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::icon(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::icon(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::icon(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::icon(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::icon(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::icon(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::icon(2),
            Trophy::Heroic => trophies::Heroic::Heroic::icon(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::icon(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::icon(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::icon(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::icon(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::icon(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::icon(2),
            Trophy::Legend => trophies::Legend::Legend::icon(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::icon(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::icon(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::icon(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::icon(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::icon(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::icon(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::icon(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::icon(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::icon(2),
            Trophy::Survivor => trophies::Survivor::Survivor::icon(0),
        }
    }

    #[inline]
    fn title(self: Trophy) -> felt252 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => trophies::BigHit::BigHit::title(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::title(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::title(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::title(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::title(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::title(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::title(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::title(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::title(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::title(2),
            Trophy::Heroic => trophies::Heroic::Heroic::title(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::title(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::title(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::title(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::title(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::title(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::title(2),
            Trophy::Legend => trophies::Legend::Legend::title(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::title(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::title(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::title(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::title(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::title(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::title(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::title(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::title(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::title(2),
            Trophy::Survivor => trophies::Survivor::Survivor::title(0),
        }
    }

    #[inline]
    fn description(self: Trophy) -> ByteArray {
        match self {
            Trophy::None => "",
            Trophy::BigHit => trophies::BigHit::BigHit::description(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::description(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::description(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::description(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::description(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::description(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::description(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::description(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::description(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::description(2),
            Trophy::Heroic => trophies::Heroic::Heroic::description(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::description(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::description(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::description(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::description(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::description(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::description(2),
            Trophy::Legend => trophies::Legend::Legend::description(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::description(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::description(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::description(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::description(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::description(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::description(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::description(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::description(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::description(2),
            Trophy::Survivor => trophies::Survivor::Survivor::description(0),
        }
    }

    #[inline]
    fn tasks(self: Trophy) -> Span<BushidoTask> {
        match self {
            Trophy::None => [].span(),
            Trophy::BigHit => trophies::BigHit::BigHit::tasks(0),
            Trophy::BruteForceI => trophies::BruteForce::BruteForce::tasks(0),
            Trophy::BruteForceII => trophies::BruteForce::BruteForce::tasks(1),
            Trophy::BruteForceIII => trophies::BruteForce::BruteForce::tasks(2),
            Trophy::BruteSquadI => trophies::BruteSquad::BruteSquad::tasks(0),
            Trophy::BruteSquadII => trophies::BruteSquad::BruteSquad::tasks(1),
            Trophy::BruteSquadIII => trophies::BruteSquad::BruteSquad::tasks(2),
            Trophy::ExplorerI => trophies::Explorer::Explorer::tasks(0),
            Trophy::ExplorerII => trophies::Explorer::Explorer::tasks(1),
            Trophy::ExplorerIII => trophies::Explorer::Explorer::tasks(2),
            Trophy::Heroic => trophies::Heroic::Heroic::tasks(0),
            Trophy::HuntersGatheringI => trophies::HuntersGathering::HuntersGathering::tasks(0),
            Trophy::HuntersGatheringII => trophies::HuntersGathering::HuntersGathering::tasks(1),
            Trophy::HuntersGatheringIII => trophies::HuntersGathering::HuntersGathering::tasks(2),
            Trophy::HuntersProwessI => trophies::HuntersProwess::HuntersProwess::tasks(0),
            Trophy::HuntersProwessII => trophies::HuntersProwess::HuntersProwess::tasks(1),
            Trophy::HuntersProwessIII => trophies::HuntersProwess::HuntersProwess::tasks(2),
            Trophy::Legend => trophies::Legend::Legend::tasks(0),
            Trophy::MagicalAssemblyI => trophies::MagicalAssembly::MagicalAssembly::tasks(0),
            Trophy::MagicalAssemblyII => trophies::MagicalAssembly::MagicalAssembly::tasks(1),
            Trophy::MagicalAssemblyIII => trophies::MagicalAssembly::MagicalAssembly::tasks(2),
            Trophy::MagicalMayhemI => trophies::MagicalMayhem::MagicalMayhem::tasks(0),
            Trophy::MagicalMayhemII => trophies::MagicalMayhem::MagicalMayhem::tasks(1),
            Trophy::MagicalMayhemIII => trophies::MagicalMayhem::MagicalMayhem::tasks(2),
            Trophy::SeasonedI => trophies::Seasoned::Seasoned::tasks(0),
            Trophy::SeasonedII => trophies::Seasoned::Seasoned::tasks(1),
            Trophy::SeasonedIII => trophies::Seasoned::Seasoned::tasks(2),
            Trophy::Survivor => trophies::Survivor::Survivor::tasks(0),
        }
    }

    #[inline]
    fn data(self: Trophy) -> ByteArray {
        ""
    }
}

impl IntoTrophyU8 of core::Into<Trophy, u8> {
    #[inline]
    fn into(self: Trophy) -> u8 {
        match self {
            Trophy::None => 0,
            Trophy::BigHit => 1,
            Trophy::BruteForceI => 2,
            Trophy::BruteForceII => 3,
            Trophy::BruteForceIII => 4,
            Trophy::BruteSquadI => 5,
            Trophy::BruteSquadII => 6,
            Trophy::BruteSquadIII => 7,
            Trophy::ExplorerI => 8,
            Trophy::ExplorerII => 9,
            Trophy::ExplorerIII => 10,
            Trophy::Heroic => 11,
            Trophy::HuntersGatheringI => 12,
            Trophy::HuntersGatheringII => 13,
            Trophy::HuntersGatheringIII => 14,
            Trophy::HuntersProwessI => 15,
            Trophy::HuntersProwessII => 16,
            Trophy::HuntersProwessIII => 17,
            Trophy::Legend => 18,
            Trophy::MagicalAssemblyI => 19,
            Trophy::MagicalAssemblyII => 20,
            Trophy::MagicalAssemblyIII => 21,
            Trophy::MagicalMayhemI => 22,
            Trophy::MagicalMayhemII => 23,
            Trophy::MagicalMayhemIII => 24,
            Trophy::SeasonedI => 25,
            Trophy::SeasonedII => 26,
            Trophy::SeasonedIII => 27,
            Trophy::Survivor => 28,
        }
    }
}

impl IntoU8Trophy of core::Into<u8, Trophy> {
    #[inline]
    fn into(self: u8) -> Trophy {
        let card: felt252 = self.into();
        match card {
            0 => Trophy::None,
            1 => Trophy::BigHit,
            2 => Trophy::BruteForceI,
            3 => Trophy::BruteForceII,
            4 => Trophy::BruteForceIII,
            5 => Trophy::BruteSquadI,
            6 => Trophy::BruteSquadII,
            7 => Trophy::BruteSquadIII,
            8 => Trophy::ExplorerI,
            9 => Trophy::ExplorerII,
            10 => Trophy::ExplorerIII,
            11 => Trophy::Heroic,
            12 => Trophy::HuntersGatheringI,
            13 => Trophy::HuntersGatheringII,
            14 => Trophy::HuntersGatheringIII,
            15 => Trophy::HuntersProwessI,
            16 => Trophy::HuntersProwessII,
            17 => Trophy::HuntersProwessIII,
            18 => Trophy::Legend,
            19 => Trophy::MagicalAssemblyI,
            20 => Trophy::MagicalAssemblyII,
            21 => Trophy::MagicalAssemblyIII,
            22 => Trophy::MagicalMayhemI,
            23 => Trophy::MagicalMayhemII,
            24 => Trophy::MagicalMayhemIII,
            25 => Trophy::SeasonedI,
            26 => Trophy::SeasonedII,
            27 => Trophy::SeasonedIII,
            28 => Trophy::Survivor,
            _ => Trophy::None,
        }
    }
}

impl TrophyPrint of core::debug::PrintTrait<Trophy> {
    #[inline]
    fn print(self: Trophy) {
        self.identifier().print();
    }
}

