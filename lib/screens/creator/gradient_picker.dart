import 'package:flutter/material.dart';
import '../../../rehmat.dart';

class GradientPicker extends StatefulWidget {
  
  const GradientPicker({Key? key}) : super(key: key);

  @override
  _GradientPickerState createState() => _GradientPickerState();
}

class _GradientPickerState extends State<GradientPicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Gradients')
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => GradientOverview(
                colors: _gradients[index].colors,
                colorName: _gradients[index].name,
              ),
              childCount: _gradients.length
            ),
          )
        ],
      ),
    );
  }
}

class GradientOverview extends StatelessWidget {

  final List<Color> colors;
  final String colorName;

  const GradientOverview({
    Key? key,
    required this.colors,
    required this.colorName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(colors),
        radius: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    )
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30.0,
                    child: Center(
                      child: Text(
                        colorName,
                        style: const TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                    ),
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<GradientSet> _gradients = [
  GradientSet(
    colors: [const Color.fromRGBO(31, 179, 237, 1), const Color.fromRGBO(17, 106, 197, 1)],
    name: 'Blue'
  ),
  GradientSet(
    colors: [const Color.fromRGBO(240, 19, 77, 1), const Color.fromRGBO(228, 0, 124, 1)],
    name: 'Pink'
  ),
  GradientSet(
    colors: [const Color.fromRGBO(255, 190, 32, 1), const Color.fromRGBO(251, 112, 71, 1)],
    name: 'Orange'
  ),
  GradientSet(
    colors: [const Color.fromRGBO(117, 0, 149, 1), const Color.fromRGBO(88, 0, 112, 0.76)],
    name: 'Indigo'
  ),
  GradientSet(
    colors: [const Color.fromRGBO(255, 255, 255, 1), const Color.fromRGBO(234, 236, 255, 1)],
    name: 'White'
  ),
  GradientSet(
    colors: [const Color(0xFF090909), const Color(0xDD202020)],
    name: 'Black'
  ),
  GradientSet(
    colors: [const Color(0xFFee9ca7), const Color(0xFFffdde1)],
    name: 'PiggyPink'
  ),
  GradientSet(
    colors: [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
    name: 'CoolBlues'
  ),
  GradientSet(
    colors: [const Color(0xFFb92b27), const Color(0xFF1565C0)],
    name: 'EveningSunshine'
  ),
  GradientSet(
    colors: [const Color(0xFF373B44), const Color(0xFF4286f4)],
    name: 'DarkOcean'
  ),
  GradientSet(
    colors: [const Color(0xFFbdc3c7), const Color(0xFF2c3e50)],
    name: 'GradeGrey'
  ),
  GradientSet(
    colors: [const Color(0xFF00416A), const Color(0xFFE4E5E6)],
    name: 'DimBlue'
  ),
  GradientSet(
    colors: [const Color(0xFFFFE000), const Color(0xFF799F0C)],
    name: 'Ver'
  ),
  GradientSet(
    colors: [const Color(0xFF4364F7), const Color(0xFF6FB1FC)],
    name: 'LightBlue'
  ),
  GradientSet(
    colors: [const Color(0xFF799F0C), const Color(0xFFACBB78)],
    name: 'LightGreen'
  ),
  GradientSet(
    colors: [const Color(0xFFffe259), const Color(0xFFffa751)],
    name: 'Mango'
  ),
  GradientSet(
    colors: [const Color(0xFF536976), const Color(0xFF292E49)],
    name: 'RoyalBlue'
  ),
  GradientSet(
    colors: [const Color(0xFF1488CC), const Color(0xFF2B32B2)],
    name: 'SkyLine'
  ),
  GradientSet(
    colors: [const Color(0xFFec008c), const Color(0xFFfc6767)],
    name: 'DarkPink'
  ),
  GradientSet(
    colors: [const Color(0xFFcc2b5e), const Color(0xFF753a88)],
    name: 'PurplePink'
  ),
  GradientSet(
    colors: [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
    name: 'SkyBlue'
  ),
  GradientSet(
    colors: [const Color(0xFF2b5876), const Color(0xFF4e4376)],
    name: 'SeaBlue'
  ),
  GradientSet(
    colors: [const Color(0xFFff6e7f), const Color(0xFFbfe9ff),],
    name: 'NoontoDusk'
  ),
  GradientSet(
    colors: [const Color(0xFFe52d27), const Color(0xFFb31217)],
    name: 'Red'
  ),
  GradientSet(
    colors: [const Color(0xFF603813), const Color(0xFFb29f94)],
    name: 'LightBrown'
  ),
  GradientSet(
    colors: [const Color(0xFF16A085), const Color(0xFFF4D03F)],
    name: 'HarmonicEnergy'
  ),
  GradientSet(
    colors: [const Color(0xFFD31027), const Color(0xFFEA384D)],
    name: 'Radish'
  ),
  GradientSet(
    colors: [const Color(0xFFEDE574), const Color(0xFFE1F5C4)],
    name: 'Sunny'
  ),
  GradientSet(
    colors: [const Color(0xFF02AAB0), const Color(0xFF00CDAC)],
    name: 'Teal'
  ),
  GradientSet(
    colors: [const Color(0xFFDA22FF), const Color(0xFF9733EE)],
    name: 'Purple'
  ),
  GradientSet(
    colors: [const Color(0xFF348F50), const Color(0xFF56B4D3)],
    name: 'Green'
  ),
  GradientSet(
    colors: [const Color(0xFFF09819), const Color(0xFFEDDE5D)],
    name: 'Yellow'
  ),
  GradientSet(
    colors: [const Color(0xFFFF512F), const Color(0xFFDD2476)],
    name: 'OrangePink'
  ),
  GradientSet(
    colors: [const Color(0xFF1A2980), const Color(0xFF26D0CE)],
    name: 'Aqua'
  ),
  GradientSet(
    colors: [const Color(0xFFFF512F), const Color(0xFFF09819)],
    name: 'Sunrise'
  ),
  GradientSet(
    colors: [const Color(0xFFEB3349), const Color(0xFFF45C43)],
    name: 'Cherry'
  ),
  GradientSet(
    colors: [const Color(0xFF1D976C), const Color(0xFF93F9B9)],
    name: 'Mojito'
  ),
  GradientSet(
    colors: [const Color(0xFFFF8008), const Color(0xFFFFC837)],
    name: 'JuicyOrange'
  ),
  GradientSet(
    colors: [const Color(0xFF16222A), const Color(0xFF3A6073)],
    name: 'Mirage'
  ),
  GradientSet(
    colors: [const Color(0xFF4776E6), const Color(0xFF8E54E9)],
    name: 'Violet'
  ),
  GradientSet(
    colors: [const Color(0xFF232526), const Color(0xFF414345)],
    name: 'LightBlack'
  ),
  GradientSet(
    colors: [const Color(0xFF00c6ff), const Color(0xFF0072ff)],
    name: 'FacebookMessenger'
  ),
  GradientSet(
    colors: [const Color(0xFFe6dada), const Color(0xFF274046)],
    name: 'Winter'
  ),
  GradientSet(
    colors: [const Color(0xFFece9e6), const Color(0xFFffffff)],
    name: 'Cloud'
  ),
  GradientSet(
    colors: [const Color(0xFF3e5151), const Color(0x993e5151)],
    name: 'Grey'
  ),
  GradientSet(
    colors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
    name: 'BeautifulGreen'
  ),
  GradientSet(
    colors: [const Color(0xFFff9a9e), const Color(0xFFfad0c4)],
    name: 'WarmFlame'
  ),
  GradientSet(
    colors: [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
    name: 'NightFade'
  ),
  GradientSet(
    colors: [const Color(0xFFfad0c4), const Color(0xFFffd1ff)],
    name: 'SpringWarmt'
  ),
  GradientSet(
    colors: [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
    name: 'JuicyPeach'
  ),
  GradientSet(
    colors: [const Color(0xFFff9a9e), const Color(0xFFfecfef)],
    name: 'LadyLips'
  ),
  GradientSet(
    colors: [const Color(0xFFf6d365), const Color(0xFFfda085)],
    name: 'SunnyMorning'
  ),
  GradientSet(
    colors: [const Color(0xFFfbc2eb), const Color(0xFFa6c1ee)],
    name: 'RainyAshville'
  ),
  GradientSet(
    colors: [const Color(0xFFfdcbf1), const Color(0xFFe6dee9)],
    name: 'FrozenDreams'
  ),
  GradientSet(
    colors: [const Color(0xFFa1c4fd), const Color(0xFFc2e9fb)],
    name: 'WinterNeva'
  ),
  GradientSet(
    colors: [const Color(0xFFd4fc79), const Color(0xFF96e6a1)],
    name: 'DustyGrass'
  ),
  GradientSet(
    colors: [const Color(0xFF84fab0), const Color(0xFF8fd3f4)],
    name: 'TemptingAzure'
  ),
  GradientSet(
    colors: [const Color(0xFFcfd9df), const Color(0xFFe2ebf0)],
    name: 'HeavyRain'
  ),
  GradientSet(
    colors: [const Color(0xFFa6c0fe), const Color(0xFFf68084)],
    name: 'AmyCrisp'
  ),
  GradientSet(
    colors: [const Color(0xFFfccb90), const Color(0xFFd57eeb)],
    name: 'MeanFruit'
  ),
  GradientSet(
    colors: [const Color(0xFFe0c3fc), const Color(0xFF8ec5fc)],
    name: 'LightBluee'
  ),
  GradientSet(
    colors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    name: 'RipeMalinka'
  ),
  GradientSet(
    colors: [const Color(0xFFfdfbfb), const Color(0xFFebedee)],
    name: 'CloudyKnoxville'
  ),
  GradientSet(
    colors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    name: 'MalibuBeach'
  ),
  GradientSet(
    colors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    name: 'NewLife'
  ),
  GradientSet(
    colors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
    name: 'TrueSunset'
  ),
  GradientSet(
    colors: [const Color(0xFF30cfd0), const Color(0xFF330867)],
    name: 'MorpheusDen'
  ),
  GradientSet(
    colors: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
    name: 'RareWind'
  ),
  GradientSet(
    colors: [const Color(0xFF5ee7df), const Color(0xFFb490ca)],
    name: 'NearMoon'
  ),
  GradientSet(
    colors: [const Color(0xFFd299c2), const Color(0xFFfef9d7)],
    name: 'WildApple'
  ),
  GradientSet(
    colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
    name: 'PlumPlate'
  ),
  GradientSet(
    colors: [const Color(0xFFfdfcfb), const Color(0xFFe2d1c3)],
    name: 'EverlastingSky'
  ),
  GradientSet(
    colors: [const Color(0xFF89f7fe), const Color(0xFF66a6ff)],
    name: 'HappyFisher'
  ),
  GradientSet(
    colors: [const Color(0xFFfddb92), const Color(0xFFd1fdff)],
    name: 'BlessingGet'
  ),
  GradientSet(
    colors: [const Color(0xFF9890e3), const Color(0xFFb1f4cf)],
    name: 'SharpeyeEagle'
  ),
  GradientSet(
    colors: [const Color(0xFFebc0fd), const Color(0xFFd9ded8)],
    name: 'LiadogaBottom'
  ),
  GradientSet(
    colors: [const Color(0xFF96fbc4), const Color(0xFFf9f586)],
    name: 'LemonGate'
  ),
  GradientSet(
    colors: [const Color(0xFF2af598), const Color(0xFF009efd)],
    name: 'ItmeoBranding'
  ),
  GradientSet(
    colors: [const Color(0xFFcd9cf2), const Color(0xFFf6f3ff)],
    name: 'ZeusMiracle'
  ),
  GradientSet(
    colors: [const Color(0xFF6a11cb), const Color(0xFF2575fc)],
    name: 'DeepBlue'
  ),
  GradientSet(
    colors: [const Color(0xFF37ecba), const Color(0xFF72afd3)],
    name: 'HappyAcid'
  ),
  GradientSet(
    colors: [const Color(0xFFebbba7), const Color(0xFFcfc7f8)],
    name: 'AwesomePine'
  ),
  GradientSet(
    colors: [const Color(0xFFfff1eb), const Color(0xFFace0f9)],
    name: 'NewYork'
  ),
  GradientSet(
    colors: [const Color(0xFFc471f5), const Color(0xFFfa71cd)],
    name: 'MixedHopes'
  ),
  GradientSet(
    colors: [const Color(0xFF48c6ef), const Color(0xFF6f86d6)],
    name: 'FlyHigh'
  ),
  GradientSet(
    colors: [const Color(0xFFfeada6), const Color(0xFFf5efef)],
    name: 'FreshMilk'
  ),
  GradientSet(
    colors: [const Color(0xFFe6e9f0), const Color(0xFFeef1f5)],
    name: 'SnowAgain'
  ),
  GradientSet(
    colors: [const Color(0xFFaccbee), const Color(0xFFe7f0fd)],
    name: 'FebruaryInk'
  ),
  GradientSet(
    colors: [const Color(0xFFe9defa), const Color(0xFFfbfcdb)],
    name: 'KindSteel'
  ),
  GradientSet(
    colors: [const Color(0xFFc1dfc4), const Color(0xFFdeecdd)],
    name: 'SoftGrass'
  ),
  GradientSet(
    colors: [const Color(0xFF0ba360), const Color(0xFF3cba92)],
    name: 'GrownEarly'
  ),
  GradientSet(
    colors: [const Color(0xFF00c6fb), const Color(0xFF005bea)],
    name: 'SharpBlues'
  ),
  GradientSet(
    colors: [const Color(0xFF74ebd5), const Color(0xFF9face6)],
    name: 'ShadyWater'
  ),
  GradientSet(
    colors: [const Color(0xFF6a85b6), const Color(0xFFbac8e0)],
    name: 'DirtyBeauty'
  ),
  GradientSet(
    colors: [const Color(0xFFa3bded), const Color(0xFF6991c7)],
    name: 'GreatWhale'
  ),
  GradientSet(
    colors: [const Color(0xFF9795f0), const Color(0xFFfbc8d4)],
    name: 'TeenNotebook'
  ),
  GradientSet(
    colors: [const Color(0xFFa7a6cb), const Color(0xFF8989ba)],
    name: 'PoliteRumors'
  ),
  GradientSet(
    colors: [const Color(0xFFf43b47), const Color(0xFF453a94)],
    name: 'RedSalvation'
  ),
  GradientSet(
    colors: [const Color(0xFF0250c5), const Color(0xFFd43f8d)],
    name: 'NightParty'
  ),
  GradientSet(
    colors: [const Color(0xFF88d3ce), const Color(0xFF6e45e2)],
    name: 'SkyGlider'
  ),
  GradientSet(
    colors: [const Color(0xFFd9afd9), const Color(0xFF97d9e1)],
    name: 'HeavenPeach'
  ),
  GradientSet(
    colors: [const Color(0xFF7028e4), const Color(0xFFe5b2ca)],
    name: 'PurpleDivision'
  ),
  GradientSet(
    colors: [const Color(0xFF13547a), const Color(0xFF80d0c7)],
    name: 'AquaSplash'
  ),
  GradientSet(
    colors: [const Color(0xFFff0844), const Color(0xFFffb199)],
    name: 'RedLove'
  ),
  GradientSet(
    colors: [const Color(0xFF93a5cf), const Color(0xFFe4efe9)],
    name: 'CleanMirror'
  ),
  GradientSet(
    colors: [const Color(0xFF434343), const Color(0xFF000000)],
    name: 'PremiumDark'
  ),
  GradientSet(
    colors: [const Color(0xFF434343), const Color(0xFF000000)],
    name: 'CochitiLake'
  ),
  GradientSet(
    colors: [const Color(0xFF92fe9d), const Color(0xFF00c9ff)],
    name: 'SummerGames'
  ),
  GradientSet(
    colors: [const Color(0xFFff758c), const Color(0xFFff7eb3)],
    name: 'PassionateRed'
  ),
  GradientSet(
    colors: [const Color(0xFF868f96), const Color(0xFF596164)],
    name: 'MountainRock'
  ),
  GradientSet(
    colors: [const Color(0xFFc79081), const Color(0xFFdfa579)],
    name: 'DesertHump'
  ),
  GradientSet(
    colors: [const Color(0xFF8baaaa), const Color(0xFFae8b9c)],
    name: 'JungleDay'
  ),
  GradientSet(
    colors: [const Color(0xFFf83600), const Color(0xFFf9d423)],
    name: 'PhoenixStart'
  ),
  GradientSet(
    colors: [const Color(0xFFb721ff), const Color(0xFF21d4fd)],
    name: 'OctoberSilence'
  ),
  GradientSet(
    colors: [const Color(0xFF6e45e2), const Color(0xFF88d3ce)],
    name: 'FarawayRiver'
  ),
  GradientSet(
    colors: [const Color(0xFFd558c8), const Color(0xFF24d292)],
    name: 'AlchemistLab'
  ),
  GradientSet(
    colors: [const Color(0xFFabecd6), const Color(0xFFfbed96)],
    name: 'OverSun'
  ),
  GradientSet(
    colors: [const Color(0xFF5f72bd), const Color(0xFF9b23ea)],
    name: 'MarsParty'
  ),
  GradientSet(
    colors: [const Color(0xFF09203f), const Color(0xFF537895)],
    name: 'EternalConstance'
  ),
  GradientSet(
    colors: [const Color(0xFFddd6f3), const Color(0xFFfaaca8)],
    name: 'JapanBlush'
  ),
  GradientSet(
    colors: [const Color(0xFFdcb0ed), const Color(0xFF99c99c)],
    name: 'SmilingRain'
  ),
  GradientSet(
    colors: [const Color(0xFFf3e7e9), const Color(0xFFe3eeff)],
    name: 'Cloudy'
  ),
  GradientSet(
    colors: [const Color(0xFFc71d6f), const Color(0xFFd09693)],
    name: 'BigMango'
  ),
  GradientSet(
    colors: [const Color(0xFF96deda), const Color(0xFF50c9c3)],
    name: 'HealthyWater'
  ),
  GradientSet(
    colors: [const Color(0xFFf77062), const Color(0xFFfe5196)],
    name: 'Amour'
  ),
  GradientSet(
    colors: [const Color(0xFFa8caba), const Color(0xFF5d4157)],
    name: 'StrongStick'
  ),
  GradientSet(
    colors: [const Color(0xFF29323c), const Color(0xFF485563)],
    name: 'BlackGray'
  ),
  GradientSet(
    colors: [const Color(0xFF16a085), const Color(0xFFf4d03f)],
    name: 'PaloAlto'
  ),
  GradientSet(
    colors: [const Color(0xFFff5858), const Color(0xFFf09819)],
    name: 'HappyMemories'
  ),
  GradientSet(
    colors: [const Color(0xFF2b5876), const Color(0xFF4e4376)],
    name: 'MidnightBloom'
  ),
  GradientSet(
    colors: [const Color(0xFF00cdac), const Color(0xFF8ddad5)],
    name: 'Crystalline'
  ),
  GradientSet(
    colors: [const Color(0xFF4481eb), const Color(0xFF04befe)],
    name: 'PartyBliss'
  ),
  GradientSet(
    colors: [const Color(0xFFdad4ec), const Color(0xFFf3e7e9)],
    name: 'ConfidentCloud'
  ),
  GradientSet(
    colors: [const Color(0xFF874da2), const Color(0xFFc43a30)],
    name: 'LeCocktail'
  ),
  GradientSet(
    colors: [const Color(0xFF4481eb), const Color(0xFF04befe)],
    name: 'RiverCity'
  ),
  GradientSet(
    colors: [const Color(0xFFe8198b), const Color(0xFFc7eafd)],
    name: 'RozenBerry'
  ),
  GradientSet(
    colors: [const Color(0xFFf794a4), const Color(0xFFfdd6bd)],
    name: 'ChildCare'
  ),
  GradientSet(
    colors: [const Color(0xFF64b3f4), const Color(0xFFc2e59c)],
    name: 'FlyingLemon'
  ),
  GradientSet(
    colors: [const Color(0xFF0fd850), const Color(0xFFf9f047)],
    name: 'HiddenJaguar'
  ),
  GradientSet(
    colors: [const Color(0xFFee9ca7), const Color(0xFFffdde1)],
    name: 'Nega'
  ),
  GradientSet(
    colors: [const Color(0xFF209cff), const Color(0xFF68e0cf)],
    name: 'Seashore'
  ),
  GradientSet(
    colors: [const Color(0xFFbdc2e8), const Color(0xFFe6dee9)],
    name: 'MarbleWall'
  ),
  GradientSet(
    colors: [const Color(0xFFe6b980), const Color(0xFFeacda3)],
    name: 'CheerfulCaramel'
  ),
  GradientSet(
    colors: [const Color(0xFF1e3c72), const Color(0xFF2a5298)],
    name: 'NightSky'
  ),
  GradientSet(
    colors: [const Color(0xFF9be15d), const Color(0xFF00e3ae)],
    name: 'YoungGrass'
  ),
  GradientSet(
    colors: [const Color(0xFFed6ea0), const Color(0xFFec8c69)],
    name: 'ColorfulPeach'
  ),
  GradientSet(
    colors: [const Color(0xFFffc3a0), const Color(0xFFffafbd)],
    name: 'GentleCare'
  ),
  GradientSet(
    colors: [const Color(0xFFcc208e), const Color(0xFF6713d2)],
    name: 'PlumBath'
  ),
  GradientSet(
    colors: [const Color(0xFFb3ffab), const Color(0xFF12fff7)],
    name: 'HappyUnicorn'
  ),
  GradientSet(
    colors: [const Color(0xFFdfe9f3), const Color(0xFFffffff)],
    name: 'GlassWater'
  ),
  GradientSet(
    colors: [const Color(0xFF40e0d0), const Color(0xFFff0080)],
    name: 'CalmDarya'
  ),
  GradientSet(
    colors: [const Color(0xFFffafbd), const Color(0xFFffc3a0)],
    name: 'Roseanna'
  ),
  GradientSet(
    colors: [const Color(0xFF2193b0), const Color(0xFF6dd5ed)],
    name: 'SeaBlueNew'
  ),
  GradientSet(
    colors: [const Color(0xFFcc2b5e), const Color(0xFF753a88)],
    name: 'PurpleLove'
  ),
  GradientSet(
    colors: [const Color(0xFFee9ca7), const Color(0xFFffdde1)],
    name: 'Piglet'
  ),
  GradientSet(
    colors: [const Color(0xFF42275a), const Color(0xFF734b6d)],
    name: 'Mauve'
  ),
  GradientSet(
    colors: [const Color(0xFFbdc3c7), const Color(0xFF2c3e50)],
    name: 'ShadesOfGrey'
  ),
  GradientSet(
    colors: [const Color(0xFFde6262), const Color(0xFFffb88c)],
    name: 'LostMemory'
  ),
  GradientSet(
    colors: [const Color(0xFF06beb6), const Color(0xFF48b1bf)],
    name: 'Socialive'
  ),
  GradientSet(
    colors: [const Color(0xFFeb3349), const Color(0xFFf45c43)],
    name: 'CherryNew'
  ),
  GradientSet(
    colors: [const Color(0xFFdd5e89), const Color(0xFFf7bb97)],
    name: 'Pinky'
  ),
  GradientSet(
    colors: [const Color(0xFF56ab2f), const Color(0xFFa8e063)],
    name: 'Lush'
  ),
  GradientSet(
    colors: [const Color(0xFF614385), const Color(0xFF516395)],
    name: 'Kashmir'
  ),
  GradientSet(
    colors: [const Color(0xFFeecda3), const Color(0xFFef629f)],
    name: 'Tranquil'
  ),
  GradientSet(
    colors: [const Color(0xFFeacda3), const Color(0xFFd6ae7b)],
    name: 'Wood'
  ),
  GradientSet(
    colors: [const Color(0xFF02aab0), const Color(0xFF00cdac)],
    name: 'GreenBeach'
  ),
  GradientSet(
    colors: [const Color(0xFF000428), const Color(0xFF004e92)],
    name: 'Frost'
  ),
  GradientSet(
    colors: [const Color(0xFFddd6f3), const Color(0xFFfaaca8)],
    name: 'Almost'
  ),
  GradientSet(
    colors: [const Color(0xFF43cea2), const Color(0xFF185a9d)],
    name: 'EndlessRiver'
  ),
  GradientSet(
    colors: [const Color(0xFF141e30), const Color(0xFF243b55)],
    name: 'RoyalBlack'
  ),
  GradientSet(
    colors: [const Color(0xFFaa076b), const Color(0xFF61045f)],
    name: 'Aubergine'
  ),
  GradientSet(
    colors: [const Color(0xFFff9966), const Color(0xFFff5e62)],
    name: 'OrangeCoral'
  ),
  GradientSet(
    colors: [const Color(0xFF36d1dc), const Color(0xFF5b86e5)],
    name: 'Scooter'
  ),
  GradientSet(
    colors: [const Color(0xFFff512f), const Color(0xFFdd2476)],
    name: 'BloodyMary'
  ),
  GradientSet(
    colors: [const Color(0xFF5433FF), const Color(0xFF20BDFF), const Color(0xFF6FB1FC)],
    name: 'Lunada'
  ),
  GradientSet(
    colors: [const Color(0xFF77A1D3), const Color(0xFF79CBCA), const Color(0xFFE684AE)],
    name: 'Hazel'
  ),
  GradientSet(
    colors: [const Color(0xFF1FA2FF), const Color(0xFF12D8FA), const Color(0xFFA6FFCB)],
    name: 'DarkSkyBlue'
  ),
  GradientSet(
    colors: [const Color(0xFF833ab4), const Color(0xFFfd1d1d), const Color(0xFFfcb045)],
    name: 'Instagram'
  ),
  GradientSet(
    colors: [const Color(0xFF12c2e9), const Color(0x0ff471ed), const Color(0xFFf64f59)],
    name: 'JShine'
  ),
  GradientSet(
    colors: [const Color(0xFF2980b9), const Color(0xFF6dd5fa), const Color(0xFFffffff)],
    name: 'CoolSky'
  ),
  GradientSet(
    colors: [const Color(0xFF7f7fd5), const Color(0xFF86a8e7), const Color(0xFF91eae4)],
    name: 'AzureLane'
  ),
  GradientSet(
    colors: [const Color(0xFF40e0d0), const Color(0xFFff8c00), const Color(0xFFff0080)],
    name: 'OrangePinkTeal'
  )
];

class GradientSet {

  final List<Color> colors;
  final String name;

  GradientSet({required this.colors, required this.name});

}