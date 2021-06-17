


class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {

  int _currentPage = 1;
  ShareDialogController _controller = ShareDialogController();
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    _controller.initElements();
    _controller.resetSelectedTags();
    _textFieldController.text = "";
    super.initState();
  }

  void goToNextStep() {
    print("Method go to next step");
    if (_controller.getSelectedEntry() != null) {
      print("Controller is not null");
      setState(() {
        _currentPage ++;
      });
    } else {
      print("Non è stato selezionato neitne, non si può procedere");
      setState(() {
        print("Non ho selezionato niente, apro il dialogo di allerta");
        _currentPage = 2;
      });
    }
  }

  void backToPageOne() {
    setState(() {
      _currentPage = 0;
    });
  }

  Widget makeFirstPage() {
    return AlertDialog(
      content: Column(
        children: [
          Container(
            width: 200,
            height: 500,
            child: ListView.separated(
              padding: const EdgeInsets.all(0), //porre a 0 se si vuole che riempa tutto lo spazion padre
              physics: ClampingScrollPhysics(),
              itemCount: _controller.getEntriesLength(),
              itemBuilder: (BuildContext context, int index) {
                return ShareDialogListItem(
                  itemIndex: index,
                  key: Key(_controller.getEntriesLength().toString()),
                  isSelected: (value) {
                    setState(() {
                      if (value) { //if selected
                        _controller.setSelectedEntry(_controller.getEntryAt(index));
                      } else {
                        _controller.setSelectedEntry(null);
                      }
                    });},
                  controller: _controller,
                );
              },
              separatorBuilder: (BuildContext context, int index) => MyDivider(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(onPressed: () => goToNextStep(), child: Text("Next")),
            ],
          ),
        ],
      ),
    );
  }

  Widget makeSecondPage() {
    return AlertDialog (
      content: Column(
        children: [
          Text("Insert Sample Infos:"),
          SizedBox(height: 20,),
          TextField(
            controller: _textFieldController,
            decoration: InputDecoration (
              border: OutlineInputBorder(),
              labelText: "Sample Name",
            ),
          ),
          SizedBox(height: 20),
          Text("Choose one or more tags"),
          SizedBox(height: 20),
          makeTagList(),
          ElevatedButton(onPressed: () => _controller.share(_textFieldController.text).then((value) => Navigator.pop(context)), child: Text("Share")),
        ],
      ),
    );
  }

  Widget makeTagList() {
    return Container(
      width: 120,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.teal,
        ),
      ),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return TagListButton(
            item: index,
            isSelected: (value) {
              if (value) {
                _controller.addToSelectedTags(index);
              } else {
                _controller.removeFromSelectedTags(index);
              }
            },
            key: Key(_controller.getTagsListLength().toString()),
            controller: _controller,
          );
        },
        separatorBuilder: (BuildContext context, int index) => MyDivider(),
        itemCount: _controller.getTagsListLength(),
      ),
    );
  }

  Widget makeNoSelectionAlertDialog() {
    return AlertDialog(
      content: Container(
        width: 200,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("No item selected, come back"),
            ElevatedButton(onPressed: backToPageOne, child: Text("OK")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage == 0) {
      return makeFirstPage();
    } else if (_currentPage == 1) {
      return makeSecondPage();
    } else {
      return makeNoSelectionAlertDialog();
    }
  }
}



class SharePage extends StatefulWidget {
  const SharePage({Key? key}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {

  int _currentPage = 1;
  ShareDialogController _controller = ShareDialogController();
  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    _controller.initElements();
    _controller.resetSelectedTags();
    _textFieldController.text = "";
    super.initState();
  }

  void goToNextStep() {
    print("Method go to next step");
    if (_controller.getSelectedEntry() != null) {
      print("Controller is not null");
      setState(() {
        _currentPage ++;
      });
    } else {
      print("Non è stato selezionato neitne, non si può procedere");
      setState(() {
        print("Non ho selezionato niente, apro il dialogo di allerta");
        _currentPage = 2;
      });
    }
  }

  void backToPageOne() {
    setState(() {
      _currentPage = 0;
    });
  }

  Widget makeFirstPage() {
    return AlertDialog(
      content: Column(
        children: [
          Container(
            width: 200,
            height: 500,
            child: ListView.separated(
              padding: const EdgeInsets.all(0), //porre a 0 se si vuole che riempa tutto lo spazion padre
              physics: ClampingScrollPhysics(),
              itemCount: _controller.getEntriesLength(),
              itemBuilder: (BuildContext context, int index) {
                return ShareDialogListItem(
                  itemIndex: index,
                  key: Key(_controller.getEntriesLength().toString()),
                  isSelected: (value) {
                    setState(() {
                      if (value) { //if selected
                        _controller.setSelectedEntry(_controller.getEntryAt(index));
                      } else {
                        _controller.setSelectedEntry(null);
                      }
                    });},
                  controller: _controller,
                );
              },
              separatorBuilder: (BuildContext context, int index) => MyDivider(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(onPressed: () => goToNextStep(), child: Text("Next")),
            ],
          ),
        ],
      ),
    );
  }

  Widget makeSecondPage() {
    return AlertDialog (
      content: Column(
        children: [
          Text("Insert Sample Infos:"),
          SizedBox(height: 20,),
          TextField(
            controller: _textFieldController,
            decoration: InputDecoration (
              border: OutlineInputBorder(),
              labelText: "Sample Name",
            ),
          ),
          SizedBox(height: 20),
          Text("Choose one or more tags"),
          SizedBox(height: 20),
          makeTagList(),
          ElevatedButton(onPressed: () => _controller.share(_textFieldController.text).then((value) => Navigator.pop(context)), child: Text("Share")),
        ],
      ),
    );
  }

  Widget makeTagList() {
    return Container(
      width: 120,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.teal,
        ),
      ),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return TagListButton(
            item: index,
            isSelected: (value) {
              if (value) {
                _controller.addToSelectedTags(index);
              } else {
                _controller.removeFromSelectedTags(index);
              }
            },
            key: Key(_controller.getTagsListLength().toString()),
            controller: _controller,
          );
        },
        separatorBuilder: (BuildContext context, int index) => MyDivider(),
        itemCount: _controller.getTagsListLength(),
      ),
    );
  }

  Widget makeNoSelectionAlertDialog() {
    return AlertDialog(
      content: Container(
        width: 200,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("No item selected, come back"),
            ElevatedButton(onPressed: backToPageOne, child: Text("OK")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage == 0) {
      return makeFirstPage();
    } else if (_currentPage == 1) {
      return makeSecondPage();
    } else {
      return makeNoSelectionAlertDialog();
    }
  }
}


class ShareDialogListItem extends StatefulWidget {

  final int itemIndex;
  final Key key;
  final ValueChanged<bool> isSelected;
  final ShareDialogController controller;

  const ShareDialogListItem({required this.itemIndex, required this.key, required this.isSelected, required this.controller}) : super(key: key);

  @override
  _ShareDialogListItemState createState() => _ShareDialogListItemState();
}

class _ShareDialogListItemState extends State<ShareDialogListItem> {

  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Row(
        children: [
          Text(widget.controller.getEntryAt(widget.itemIndex).getFilename()),
          SizedBox(width: 10,),
          ElevatedButton(
              onPressed: () => widget.controller.playRecord(widget.itemIndex),
              child: Text("Play")
          ),
          SizedBox(width: 20),
          isSelected ? Container(
              width: 40,
              height: 10,
              child: Align( //se lo seleziono aggiunge il pallino blu
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                  ),
                ),
              )
          ) : Container(width: 40, height: 10),
        ],
      ),
    );


  }
}








