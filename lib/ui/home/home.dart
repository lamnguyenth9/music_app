import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mp3/data/model/song.dart';
import 'package:mp3/ui/discovery/discovery.dart';
import 'package:mp3/ui/home/viewmodel.dart';
import 'package:mp3/ui/now_playing/audio_player_manager.dart';
import 'package:mp3/ui/now_playing/play.dart';
import 'package:mp3/ui/setting/setting.dart';
import 'package:mp3/ui/user/user.dart';

class MusicHome extends StatelessWidget {
  const MusicHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true
      ),
      home: MusicHomePage(),
    );
  }

}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs=[
       HomeTab(),
       DiscoveryTab(),
       AccountTab(),
       SettingTab()
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Music App"),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.album), label: 'Discovery'
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Account'
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'
              )
          ]
          ), 
        tabBuilder: (context, index) {
          return _tabs[index];
        },),
    );
  }
}
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeTabPage();
  }
}
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs =[];
  late MusicAppViewModel viewModel ;
  @override
  void initState() {
    viewModel= MusicAppViewModel();
    viewModel.loadSongs();
    observeData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }
  @override
  void dispose() {
    viewModel.songStream.close();
    AudioPlayerManager().dispose();
    super.dispose();
  }
  Widget getBody(){
    bool showLoading = songs.isEmpty;
    if(showLoading){
      return getProgressBar();
    }else{
      return getListView();
    }
  }
  Widget getListView(){
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return getRow(index);
      }, 
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      }, 
      itemCount: songs.length);
  }
  Widget getRow(int index){
    return _songItemSection(
      parent: this,
      song: songs[index],
    );
  }
  Widget getProgressBar(){
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
  void observeData(){
    viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
     });
  }
  void showBottom(){
    showModalBottomSheet(context: context, builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          height: 400,
          color: Colors.grey,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Modal Bottom Sheet'),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child: Text("Close Button Sheet"))
                ],
            ),
          ),
        ),
      );
    },);
  }
  void navigate(Song song){
   Navigator.push(context, CupertinoPageRoute(builder: (_)=>NowPlaying(
    songs: songs,
    playingSong: song,
   )));
  }
}
class _songItemSection extends StatelessWidget {
  final _HomeTabPageState parent;
  final Song song;
  _songItemSection({
    
    required this.parent,
    required this.song
  });
  
  @override
  Widget build(BuildContext context) {
   return ListTile(
    contentPadding: EdgeInsets.only(
      left: 24,right: 8
    ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: FadeInImage.assetNetwork(
        placeholder: 'assets/tool.png', 
        image: song.image,
        width: 48,
        height: 48,
        imageErrorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/tool.png',
          width: 48,
          height: 48,);
        },),
      ),
        title: Text(song.title,),
        subtitle: Text(
          song.artist
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_horiz),
          onPressed: (){
             parent.showBottom();
          },
        ),
        onTap: (){
          parent.navigate(
            song
          );
        },

   );
  }

}