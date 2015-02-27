import controlP5.*;
import java.util.Collections;
import java.util.Arrays;
import gifAnimation.*;
import fisica.*;
import org.gicentre.utils.multisketch.*;


Graph statGraph;
ArrayList <PokemonPoint> pokemon;
ArrayList <PokemonPoint> selectedPokemon;
BufferedReader statsReader;
BufferedReader pokemonReader;
BufferedReader typeReader;
PApplet parent;
ControlP5 cp5;
Button button;
CheckBox checkbox;
Boolean exclusive = false;
Boolean showTT = false;
Boolean clear = false;
Boolean animate = false;
Tooltip tt;
DropdownList dropdownListX;
DropdownList dropdownListY;
DropdownList dropdownListPok;
int xStat = 5;
int yStat = 1;
String[] stats = {
  "HP", "ATTACK", "DEFENSE", 
  "SPECIAL ATTACK", "SPECIAL DEFENSE", "SPEED"
};
color[] typePalette = {
  color(0, 0, 0), color(168, 168, 120), color(192, 48, 40), 
  color(168, 144, 240), color(160, 64, 160), color(224, 192, 104), 
  color(184, 160, 56), color(168, 184, 32), color(112, 88, 152), 
  color(184, 184, 208), color(240, 128, 48), color(104, 144, 240), 
  color(120, 200, 80), color(248, 208, 48), color(248, 88, 136), 
  color(152, 216, 216), color(112, 56, 248), color(112, 88, 72), 
  color(238, 153, 172)
};

String[]  types = {
  "", "Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", 
  "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", 
  "Ice", "Dragon", "Dark", "Fairy"
};


void setup() {
  cp5 = new ControlP5(this);
  parent = this;
  size(800, 600);
  textAlign(CENTER);
  if (frame != null) {
    frame.setResizable(true);
  }
  pokemon = new ArrayList<PokemonPoint>();
  selectedPokemon = new ArrayList<PokemonPoint>();
  tt = new Tooltip(0);
  statGraph = new Graph();
  fillPokemonArray();

  imageMode(CENTER);
  
  PopupWindow win = new PopupWindow(this, new pokeTotal()); 
  win.setVisible(true);
  
  button = cp5.addButton("Animate")
    .setValue(1)
      .setPosition(500,80)
        .setId(1);
        
  checkbox = cp5.addCheckBox("checkbox")
    .setPosition(10, 10)
      .setSize(20, 20)
        .setItemsPerRow(9)
          .setSpacingColumn(60)
            .setSpacingRow(10);

  for (int i = 1; i < 19; i++) {
    checkbox.addItem(types[i], i);
    checkbox.getItem(i-1)
      .setColorForeground(color(255))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setColorBackground(typePalette[i]);
  }

  checkbox.addItem("exclusive", 19)
    .setColorForeground(color(255))
      .setColorActive(color(255))
        .setColorLabel(color(255));

  // X-axis
  dropdownListX = cp5.addDropdownList("dropdownListX")
    .addItems(stats)
      .setPosition(200, 80)
        .setSize(80, 100)
          .setValue(0)
            .setLabel("X Axis");

  // Y-axis
  dropdownListY = cp5.addDropdownList("dropdownListY")
    .addItems(stats)
      .setPosition(400, 80)
        .setSize(80, 100)
            .setTitle("Y Axis");

  // Displayed Pokemon
  dropdownListPok = cp5.addDropdownList("dropdownListPok")
      .setPosition(600, 80)
        .setSize(80, 100)
            .setTitle("All Pokemon");
            
  animate = false;
}



void draw() {
  if (selectedPokemon.size() == 0)
    statGraph.stopDrawTop();
  if (clear){
    statGraph.stopDrawTop();
    clear = false;
  }
  background(60, 60, 60);
  fill(60);
  noStroke();
  checkbox.setItemsPerRow(width/88);
  statGraph.draw();
  if (showTT){
    tt.show();
    if(mousePressed && tt.overEvent())
      tt.update();
  }
  //noLoop();
}

void mousePressed(){
  print(showTT);
  if(showTT){
    if ((!tt.overEvent())){
      showTT = false;
      for (int i = 0; i < selectedPokemon.size(); i++){
        selectedPokemon.get(i).undim();
        selectedPokemon.get(i).overEvent();
      }
    }
  }
  else {
    for (int i = 0; i < selectedPokemon.size(); i++){
      if(selectedPokemon.get(i).overEvent()){
        for (int j = 0; j < selectedPokemon.size(); j++)
          selectedPokemon.get(j).dim();
        selectedPokemon.get(i).undim();
        statGraph.drawTop(i);
        tt.reassign(i);
        showTT = true;
        break;
      }
      else
        selectedPokemon.get(i).undim();
    }
  }
}
public void Animate(int theValue)
{
  if(animate)
    animate = false;
    else
      animate = true;
}

void fillPokemonArray() {
  String statsLine;
  String [] statsPieces;
  String pokemonLine;
  String [] pokemonPieces;
  String typeLine;
  String [] typePieces;
  int typecount = 0;
  int currentId = 0;

  // temp values
  String t_name;
  int t_id, t_hp, t_atk, t_def, t_satk, t_sdef, t_spd, t_t1, t_t2;
  t_id = 0;
  t_t1 = 0;
  t_t2 = 0;
  // skip first line
  pokemonReader = createReader ("pokemon.csv");
  try {
    pokemonReader.readLine();
    pokemonLine = pokemonReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    pokemonLine = null;
  }

  // skip first line
  typeReader = createReader ("pokemon_types.csv");
  try {
    typeReader.readLine();
    typeLine = typeReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    typeLine = null;
  }

  // skip first line
  statsReader = createReader ("pokemon_stats.csv");
  try {
    statsReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    statsLine = null;
  }

  // main loop
  while (t_id < 719/*pokemonLine != null*/) {
    pokemonPieces = split(pokemonLine, ",");
    t_id++;
    t_name = pokemonPieces[1];
    println(t_name);

    typePieces = split(typeLine, ",");
    while (t_id == Integer.parseInt (typePieces[0])) {
      typecount++;
      if (typecount == 1)
        t_t1 = Integer.parseInt(typePieces[1]);
      else if (typecount == 2)
        t_t2 = Integer.parseInt(typePieces[1]);
      try {
        typeLine = typeReader.readLine();
      }
      catch (IOException e) {
        e.printStackTrace();
        typeLine = null;
      }
      typePieces = split(typeLine, ",");
    }

    // do this for each stat
    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ",");
    t_hp = Integer.parseInt(statsPieces[2]);

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ",");
    t_atk = Integer.parseInt(statsPieces[2]);

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ",");
    t_def = Integer.parseInt(statsPieces[2]);

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ",");
    t_satk = Integer.parseInt(statsPieces[2]);

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }    
    statsPieces = split(statsLine, ",");
    t_sdef = Integer.parseInt(statsPieces[2]);

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }    
    statsPieces = split(statsLine, ",");
    t_spd = Integer.parseInt(statsPieces[2]);

    // make sure to differentiate between single type and multitype
    if (typecount == 1)
      pokemon.add(new PokemonPoint(t_name, t_id, t_hp, t_atk, t_def, t_satk, t_sdef, t_spd, t_t1));
    else if (typecount == 2)
      pokemon.add(new PokemonPoint(t_name, t_id, t_hp, t_atk, t_def, t_satk, t_sdef, t_spd, t_t1, t_t2));

    typecount = 0;
    try {
      pokemonLine = pokemonReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      pokemonLine = null;
    }
  }
}



void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(checkbox)) {
    int count = 0;
    int c_count = 0;
    ArrayList<String> poks = new ArrayList<String>();
    Object[] pok;
    // get count of selected checkboxes
    for (int i = 0; i < checkbox.getArrayValue().length; i++)
      if (checkbox.getArrayValue()[i] == 1)
        count++;
    print(count);
    if (checkbox.getArrayValue()[18] == 1) {
      exclusive = true;
    }
    else {
      exclusive = false;
    }
    selectedPokemon = new ArrayList<PokemonPoint>();

    if ((exclusive && (count < 4)) || !exclusive) {
      boolean contained = false;
      PokemonPoint temp;
      for (int i = 0;i < pokemon.size(); i++) {
        temp = pokemon.get(i);

        if (!exclusive ) {
          if (temp.isDualType) {
            if ((checkbox.getArrayValue()[temp.type1-1] == 1) || (checkbox.getArrayValue()[temp.type2-1] == 1))
              contained = true;
          }
          else if ((checkbox.getArrayValue()[temp.type1-1] == 1))
            contained = true;
        }
        else if (exclusive && (count == 2)) {
          if (temp.isDualType)
            contained = false;
          else if (checkbox.getArrayValue()[temp.type1-1] == 1)
            contained = true;
        }    
        else if (exclusive && (count == 3)) {
          if (!temp.isDualType)
            contained = false;
          else if ((checkbox.getArrayValue()[temp.type1-1] == 1) &&
            (checkbox.getArrayValue()[temp.type2-1] == 1))
            contained = true;
          else
            contained = false;
        }
        if (contained) {
          selectedPokemon.add(temp);
          contained = false;
          poks.add(temp.name);
          println(poks.get(0).toString());
        }
      }
    }
    statGraph.topId = 0;
    showTT = false;
    dropdownListPok.clear();
    dropdownListPok.addItem("ALL POKEMON", -1);
    Collections.sort(poks);
    Collections.sort(selectedPokemon);
    pok = poks.toArray();
    dropdownListPok.addItems(Arrays.copyOf(pok,pok.length,String[].class));
  }
  else if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());

    if (theEvent.getGroup().equals (dropdownListX)) { // X Axis Chosen
      xStat = (int)theEvent.getGroup().getValue();
      statGraph.stopDrawTop();
      clear = true;
      println(xStat);
      //statGraph.getMaxStat(xStat,yStat);
      showTT = false;
    }
    else if (theEvent.getGroup().equals (dropdownListY)) { // Y Axis Chosen
      yStat = (int)theEvent.getGroup().getValue();
      //statGraph.getMaxStat(xStat,yStat);
      clear = true;
      statGraph.stopDrawTop();
      println(yStat);
      showTT = false;
    }
    else if (theEvent.getGroup().equals (dropdownListPok)) { // Pokemon List Chosen
      if((int)theEvent.getGroup().getValue() > -1) {
        for (int i = 0; i < selectedPokemon.size(); i++)   
          selectedPokemon.get(i).dim();
        if(selectedPokemon.size() > 0)
          statGraph.drawTop((int)theEvent.getGroup().getValue());
        tt.reassign((int)theEvent.getGroup().getValue());
        showTT = true;
      }
      else {
        for (int i = 0; i < selectedPokemon.size(); i++)
          selectedPokemon.get(i).undim();
          showTT = false;
      }
    }
  }
}


/**************************************************************
 * POKEMONPOINT CLASS
 **************************************************************/
class PokemonPoint implements Comparable {
  String name;
  int id;
  int hp;
  int atk;
  int def;
  int satk;
  int sdef;
  int spd;
  int type1;
  int type2;
  int i;
  PImage sprite;
  PImage[] anim;
  boolean isDualType;
  boolean loaded;
  boolean dim;
  float mx, my;

  // single type pokemon
  public PokemonPoint (String mName, int number, int hitpoints, int attack, int defense, int s_attack, int s_defense, int speed, int t1) {
    name = mName;
    id = number;
    hp = hitpoints;
    atk = attack;
    def = defense;
    satk = s_attack;
    sdef = s_defense;
    spd = speed;
    type1 = t1;
    isDualType = false;
    loaded = false;
    dim = false;
  }

  // dual type pokemon
  public PokemonPoint (String mName, int number, int hitpoints, int attack, int defense, int s_attack, int s_defense, int speed, int t1, int t2) {
    name = mName;
    id = number;
    hp = hitpoints;
    atk = attack;
    def = defense;
    satk = s_attack;
    sdef = s_defense;
    spd = speed;
    type1 = t1;
    type2 = t2;
    isDualType = true;
    loaded = false;
    dim = false;
  }


  void loadSprite() {
    if (loaded == false) {
      sprite = loadImage("images/"+ name + ".gif");
      anim = Gif.getPImages(parent, "images/"+ name + ".gif");
      println("images/"+ name + ".gif");
    }
    loaded = true;
  }
  
  boolean overEvent() { // Checks if pointer is over circle
    float disX = mx - mouseX;
    float disY = my - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < 25 ){
      //print (mTag);
      print (name);
      return true;
    }
    else
      return false;
  }
  
  void dim() {
    dim = true;
  }
    
  void undim() {
    dim = false;
  }

  void draw(float x, float y)
  {
    if(!dim) {
      tint (255,255);
      if(animate){
        i = (i+1)%anim.length;
        image(anim[i], x, y);
      }
      else
        image(anim[0], x, y);
      mx = x;
      my = y;
    }
    else {
      tint(255,100);
      if(animate){
        i = (i+1)%anim.length;
        image(anim[i], x, y);
      }
      else
        image(anim[0], x, y);
      mx = x;
      my = y;
    }
  }

  @Override
  public boolean equals(Object object){
    boolean sameSame = false;

    if (object != null && object instanceof PokemonPoint)
    {
      if (id == ((PokemonPoint)object).id)
        return true;
    }
    return sameSame;
  }
  @Override
  public int compareTo(Object object) {
    return name.compareTo(((PokemonPoint)object).name);
  }  
}


/**************************************************************
 * TOOLTIP CLASS
 **************************************************************/
public class Tooltip {
  int pokId;
  int baseX;
  int baseY;
  int lastX;
  int lastY;
  int lengthX;
  boolean barView;
  boolean radialView;
  
  PokemonPoint temp;
  
  public Tooltip (int id) {
    pokId = id;
    baseX = 100;
    baseY = 100;
    barView = true;
    radialView = false;
  }
  
  boolean overEvent() { // Checks if pointer is over circle
    if ((mouseX > baseX) && (mouseX < (baseX + 460)) &&
        (mouseY > baseY) && (mouseY < baseY + 220)){
      return true;
    }
    else if((mouseX > baseX + 10 && mouseX < baseX + 100) &&
            (mouseY > baseY + 225 && mouseY < baseY + 245)){
      return true;
    }
    else if((mouseX > baseX + 10 && mouseX < baseX + 100) &&
            (mouseY > baseY + 250 && mouseY < baseY + 270)){
      return true;
    }
    else
      return false;
  }
  
  int maxStat()
  {
    int x = 0;
    
    if (temp.hp > x)
      x = temp.hp;
    if (temp.atk > x)
      x = temp.atk;
    if (temp.def > x)
      x = temp.def;
    if (temp.satk > x)
      x = temp.satk;
    if (temp.sdef > x)
      x = temp.sdef;
    if (temp.spd > x)
      x = temp.spd;
      return x;
  }
  
  void update (){
    if((mouseX > baseX + 10 && mouseX < baseX + 100) &&
       (mouseY > baseY + 225 && mouseY < baseY + 245)){
      barView = true;
      radialView = false;
    }
    else if((mouseX > baseX + 10 && mouseX < baseX + 100) &&
            (mouseY > baseY + 250 && mouseY < baseY + 270)){
      barView = false;
      radialView = true;
    }
    else {
      baseX = mouseX-200;
      baseY = mouseY-100;
    }
  }
  
  void reassign (int id){
    pokId = id;
  }
  
  color computeColor(int stat)
  {
    color c;
    
    if ( stat >= 170 )
      c = color(0,255,0);
    else if ( stat >= 85)
      c = color(255-(stat-85)*3,255,0);
    else
      c = color(255,stat*3,0);
    return c;
  }
  
  public void show () {
    temp = selectedPokemon.get(pokId);
    lengthX = maxStat();
    int space = baseX + 20 + 22*temp.name.length();
    fill (10,10,10,200);
    rect (baseX , baseY, 200 + 1.5*lengthX, 220);
    fill (255,255,255);
    textSize (30);
    textAlign (LEFT);
    text (temp.name.toUpperCase(), baseX + 20, baseY + 30);
    fill (255);
    noStroke();
    ellipse (baseX + 60,baseY+100,70,70);
    temp.draw(baseX + 60,baseY+100);
    textAlign(CENTER);
    textSize(15);
    if(temp.isDualType){
      fill(typePalette[temp.type1]);
      rect(space-1,baseY + 10,71,20);
      fill(255);
      text(types[temp.type1].toUpperCase(),space+35,baseY + 25);
    
      fill(typePalette[temp.type2]);
      rect(space+79,baseY + 10,71,20);
      fill(255);
      text(types[temp.type2].toUpperCase(),space+113,baseY + 25);
    }
    else{
      fill(typePalette[temp.type1]);
      rect(space-1,baseY + 10,71,20);
      fill(255);
      text(types[temp.type1].toUpperCase(),space+35,baseY + 25);
    }
    if(barView){
      textSize (20);
      textAlign (RIGHT);
    
      text("HP",baseX + 170,baseY + 60);
      fill(computeColor(temp.hp));
      rect(baseX + 180,baseY + 45,1.5*temp.hp,15);
    
      fill(255);
      text("ATK",baseX + 170,baseY + 80);
      fill(computeColor(temp.atk));
      rect(baseX + 180,baseY + 65,1.5*temp.atk,15);
    
      fill(255);
      text("DEF",baseX + 170,baseY + 100);
      fill(computeColor(temp.def));
      rect(baseX + 180,baseY + 85,1.5*temp.def,15);
     
      fill(255);
      text("S.ATK",baseX + 170,baseY + 120);
      fill(computeColor(temp.satk));
      rect(baseX + 180,baseY + 105,1.5*temp.satk,15);
    
      fill(255);
      text("S.DEF",baseX + 170,baseY + 140);
      fill(computeColor(temp.sdef));
      rect(baseX + 180,baseY + 125,1.5*temp.sdef,15);
    
      fill(255);
      text("SPD",baseX + 170,baseY + 160);
      fill(computeColor(temp.spd));
      rect(baseX + 180,baseY + 145,1.5*temp.spd,15);
    
      textAlign(LEFT);
      fill(64);
      textSize(15);
      text(temp.hp,baseX + 180,baseY + 60-2);
      text(temp.atk,baseX + 180,baseY + 80-2);
      text(temp.def,baseX + 180,baseY + 100-2);
      text(temp.satk,baseX + 180,baseY + 120-2);
      text(temp.sdef,baseX + 180,baseY + 140-2);
      text(temp.spd,baseX + 180,baseY + 160-2);
    }
    else if (radialView){
      float PI = 3.14159;
      float xCoor;
      if(lengthX <= 100){
        xCoor = baseX + 200;
      } else if (lengthX < 200){
        xCoor = baseX + 300;
      } else {
        xCoor = baseX + 360;
      }
      float yCoor = baseY + 120;
      float[] angles = {-PI, -2*PI/3, -PI/3, 0, PI/3, 2*PI/3, PI};

      stroke(0);
      textAlign(CENTER, CENTER);
      fill(computeColor(temp.hp));
      arc(xCoor, yCoor, temp.hp, temp.hp, angles[0], angles[1], PIE);
      fill(150);
      text("HP", xCoor - 50, yCoor - 30);
      text(temp.hp, xCoor - 35, yCoor - 15);

      fill(computeColor(temp.atk));
      arc(xCoor, yCoor, temp.atk, temp.atk, angles[1], angles[2], PIE);
      fill(150);
      text("ATK", xCoor, yCoor - 50);
      text(temp.atk, xCoor, yCoor - 30);

      fill(computeColor(temp.def));
      arc(xCoor, yCoor, temp.def, temp.def, angles[2], angles[3], PIE);
      fill(150);
      text("DEF", xCoor + 50, yCoor - 30);
      text(temp.def, xCoor + 35, yCoor -15);

      fill(computeColor(temp.satk));
      arc(xCoor, yCoor, temp.satk, temp.satk, angles[3], angles[4], PIE);
      fill(150); 
      text("SATK", xCoor + 50, yCoor + 35);
      text(temp.satk, xCoor + 35, yCoor + 15);
      
      fill(computeColor(temp.sdef));
      arc(xCoor, yCoor, temp.sdef, temp.sdef, angles[4], angles[5], PIE);
      fill(150);
      text("SDEF", xCoor, yCoor + 45);
      text(temp.sdef, xCoor, yCoor + 25);

      fill(computeColor(temp.spd));
      arc(xCoor, yCoor, temp.spd, temp.spd, angles[5], angles[6], PIE);
      fill(150);
      text("SPD", xCoor - 50, yCoor + 35);
      text(temp.spd, xCoor - 35, yCoor + 15);
    
      noStroke();
    }
    fill(127);
    rect(baseX + 10, baseY + 225, 90, 20);
    rect(baseX + 10, baseY + 250, 90, 20);
    fill(255);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("Bar View", baseX + 52, baseY + 230);
    text("Radial View", baseX + 52, baseY + 256);
  }
  
}
/**************************************************************
 * GRAPH CLASS
 **************************************************************/
public class Graph {
  float xscale;
  float yscale;
  float maxX;
  float maxY;
  float gWidth;
  float gHeight;
  int topId;
  boolean top;

  PokemonPoint temp;
  public Graph () {
    top = false;
    maxX = 0;
    maxY = 0;
  }

  void draw () {
    int x = 0;
    int y = 0;

    gWidth = width-190;
    gHeight = height-190;
    fill (255, 255, 255);
    rect (70, 90, width-100, height-160);

    fill(0);
    stroke(5);

    getMaxStat(xStat, yStat);

    xscale = (width - 200)/maxX;
    yscale = (height - 200)/maxY;

    gWidth = width-200;
    gHeight = height-200;
    fill(100, 100, 130);
    textSize(20);
    textAlign(LEFT);
    text (stats[yStat], 105, 120);
    textAlign(RIGHT);
    text (stats[xStat], width - 105, height - 105);
    textSize(10);
    stroke(200, 200, 180);
    fill(0);

    textAlign(CENTER);
    for (int i = 0; i < 8; i++)
    {
      stroke(200, 200, 180);
      line (100 + (gWidth/7)*i, 100, 100 + (gWidth/7)*i, (height-100));

      text(round((maxX/7)*i), 90+(gWidth/7)*i, height-90);
    }
    for (int i = 0; i < 8; i++)
    {
      stroke(200, 200, 180);
      line (100, 100 + (gHeight/7)*i, width-100, 100 + (gHeight/7)*i);
      text(round((maxY/7)*i), 83, (height-100) - (gHeight/7)*i);
    }
    //print(maxY);
    stroke(10);
    line (100, 100, 100, height-100);
    line (100, height-100, width-100, height-100);

    for (int i = 0; i < selectedPokemon.size(); i ++) {
      temp = selectedPokemon.get(i);
      temp.loadSprite();

      switch(xStat) {
      case 0:
        x = temp.hp;
        break;
      case 1:
        x = temp.atk;
        break;         
      case 2:
        x = temp.def;
        break;                
      case 3:
        x = temp.satk;         
        break;
      case 4:
        x = temp.sdef; 
        break;          
      case 5:
        x = temp.spd; 
        break;
      }
      switch(yStat) {
      case 0:
        y = temp.hp; 
        break;
      case 1:
        y = temp.atk; 
        break;   
      case 2:
        y = temp.def; 
        break;  
      case 3:
        y = temp.satk; 
        break;   
      case 4:
        y = temp.sdef; 
        break;   
      case 5:
        y = temp.spd; 
        break;
      }

      temp.draw(100 + x * xscale, height - 100 - y * yscale);
    }
    
    if ((top == true) && (clear == false)){
      temp = selectedPokemon.get(topId);
      temp.loadSprite();
      
      switch(xStat) {
      case 0:
        x = temp.hp;
        break;
      case 1:
        x = temp.atk;
        break;         
      case 2:
        x = temp.def;
        break;                
      case 3:
        x = temp.satk;         
        break;
      case 4:
        x = temp.sdef; 
        break;          
      case 5:
        x = temp.spd; 
        break;
      }
      switch(yStat) {
      case 0:
        y = temp.hp; 
        break;
      case 1:
        y = temp.atk; 
        break;   
      case 2:
        y = temp.def; 
        break;  
      case 3:
        y = temp.satk; 
        break;   
      case 4:
        y = temp.sdef; 
        break;   
      case 5:
        y = temp.spd; 
        break;
      }
      temp.undim();
      temp.draw(100 + x * xscale, height - 100 - y * yscale);
    }
  }
  void drawTop (int id) {
    topId = id;
    top = true;
  }
  void stopDrawTop(){
    top = false;
  }
  void getMaxStat(int idX, int idY)
  {
    float x = 0;
    float y = 0;
    PokemonPoint temp;
    for (int i = 0; i < selectedPokemon.size(); i++)
    {
      temp = selectedPokemon.get(i);

      switch(idX) {
      case 0:
        if (temp.hp > x)
          x = temp.hp;
        break;
      case 1:
        if (temp.atk > x)
          x = temp.atk;         
        break;
      case 2:
        if (temp.def > x)
          x = temp.def;
        break;         
      case 3:
        if (temp.satk > x)
          x = temp.satk;
        break;         
      case 4:
        if (temp.sdef > x)
          x = temp.sdef;
        break;          
      case 5:
        if (temp.spd > x)
          x = temp.spd;
        break;
      }
      switch(idY) {
      case 0:
        if (temp.hp > y)
          y = temp.hp;
        break;
      case 1:
        if (temp.atk > y)
          y = temp.atk;
        break;         
      case 2:
        if (temp.def > y)
          y = temp.def;
        break;         
      case 3:
        if (temp.satk > y)
          y = temp.satk;
        break;         
      case 4:
        if (temp.sdef > y)
          y = temp.sdef;
        break;          
      case 5:
        if (temp.spd > y)
          y = temp.spd;
        break;
      }
    }
    maxX = x;
    //print (" Max X " + maxX + "Max Y " + maxY);
    maxY = y;
  }
}
class pokeTotal extends EmbeddedSketch
{
ArrayList <PokemonPoint> pokemon;
ArrayList pokeCircle;
float circleX, circleY;
BufferedReader statsReader;
BufferedReader pokemonReader;
BufferedReader typeReader;
BufferedReader speciesReader;
ControlP5 cp5;
CheckBox statBox;

String[] stats = {
  "HP", "ATTACK", "DEFENSE", 
  "SPECIAL ATTACK", "SPECIAL DEFENSE", "SPEED"
};

  color[] typePalette = {
    color(0, 0, 0), color(168, 168, 120), color(192, 48, 40), 
    color(168, 144, 240), color(160, 64, 160), color(224, 192, 104), 
    color(184, 160, 56), color(168, 184, 32), color(112, 88, 152), 
    color(184, 184, 208), color(240, 128, 48), color(104, 144, 240), 
    color(120, 200, 80), color(248, 208, 48), color(248, 88, 136), 
    color(152, 216, 216), color(112, 56, 248), color(112, 88, 72), 
    color(238, 153, 172)
  };
  
  color[] statPalette = { color(100,200,245), color(230,50,95), color(220,190,220),
  color(180,100,250), color(45,185,30), color(255,180,40)
  };

 
 
FWorld pokeWorld;
FBox pokeBox;
 
void setup() {
  cp5 = new ControlP5(this);
  size(1000, 600);
  if (frame != null) {
    frame.setResizable(true);
    
    
  }
  
  

  Fisica.init(this);
  
  pokeWorld = new FWorld();
  pokeWorld.setGravity(0,0);
  pokeWorld.setEdges();
  
  
  pokemon = new ArrayList<PokemonPoint>();
  fillPokemonArray();
  
  

  imageMode(CENTER);
  
  statBox = cp5.addCheckBox("checkbox")
    .setPosition(10,10)
     .setSize(20,20)
      .setItemsPerRow(6)
       .setSpacingColumn(100);
        

  for(int i = 0; i<6; i++){
    statBox.addItem(stats[i],i);
     statBox.getItem(i)
       .setColorForeground(color(255))
        .setColorActive(color(255))
          .setColorLabel(color(255))
            .setColorBackground(statPalette[i]);
  }

  hpCircle();
}


 
void draw() {
 super.draw();
 background(60,60,60);
 for(int i = 0; i<450; i++){
   FCircle circle = (FCircle)pokeCircle.get(i);
   circle.addForce(0,100);
 }
 
 pokeWorld.step();
 pokeWorld.draw(this);
 
}
 




class PokemonPoint implements Comparable {
  String name;
  int id;
  int hp;
  int atk;
  int def;
  int satk;
  int sdef;
  int spd;
  int type1;
  int type2;


  // single type pokemon
  public PokemonPoint (String mName, int number, int hitpoints, int attack, int defense, int s_attack, int s_defense, int speed, int t1) {
    name = mName;
    id = number;
    hp = hitpoints;
    atk = attack;
    def = defense;
    satk = s_attack;
    sdef = s_defense;
    spd = speed;
    type1 = t1;
   
  }

  // dual type pokemon
  public PokemonPoint (String mName, int number, int hitpoints, int attack, int defense, int s_attack, int s_defense, int speed, int t1, int t2) {
    name = mName;
    id = number;
    hp = hitpoints;
    atk = attack;
    def = defense;
    satk = s_attack;
    sdef = s_defense;
    spd = speed;
    type1 = t1;
    type2 = t2;

  }

  @Override
  public boolean equals(Object object){
    boolean sameSame = false;

    if (object != null && object instanceof PokemonPoint)
    {
      if (id == ((PokemonPoint)object).id)
        return true;
    }
    return sameSame;
  }
  @Override
  public int compareTo(Object object) {
    return name.compareTo(((PokemonPoint)object).name);
  }  
}

void hpCircle(){
     pokeWorld.clear();
     pokeCircle = new ArrayList();
   for(int i =0; i<450; i++){
     PokemonPoint tempPoke;
     tempPoke = pokemon.get(i);
     FCircle circle = new FCircle(tempPoke.hp/2);
     circle.setPosition(width/2+random(-300,300),height/2+random(-400,100));
     circle.setFillColor(typePalette[tempPoke.type1]);
     circle.setNoStroke();
     pokeCircle.add(circle);
     pokeWorld.add(circle);
   }
}
void atkCircle(){
  pokeWorld.clear();
     
     pokeCircle = new ArrayList();
   for(int i =0; i<450; i++){
     PokemonPoint tempPoke;
     tempPoke = pokemon.get(i);
     FCircle circle = new FCircle(tempPoke.atk/2);
     circle.setPosition(width/2+random(-300,300),height/2+random(-400,100));
     circle.setFillColor(typePalette[tempPoke.type1]);
     circle.setNoStroke();
     pokeCircle.add(circle);
     pokeWorld.add(circle);
   }
}
void defCircle(){
  pokeWorld.clear();
     pokeCircle = new ArrayList();
   for(int i =0; i<450; i++){
     PokemonPoint tempPoke;
     tempPoke = pokemon.get(i);
     FCircle circle = new FCircle(tempPoke.def/2);
     circle.setPosition(width/2+random(-300,300),height/2+random(-400,100));
     circle.setFillColor(typePalette[tempPoke.type1]);
     circle.setNoStroke();
     pokeCircle.add(circle);
     pokeWorld.add(circle);
   }
}
void satkCircle(){
  pokeWorld.clear();
     pokeCircle = new ArrayList();
   for(int i =0; i<450; i++){
     PokemonPoint tempPoke;
     tempPoke = pokemon.get(i);
     FCircle circle = new FCircle(tempPoke.satk/2);
     circle.setPosition(width/2+random(-300,300),height/2+random(-400,100));
     circle.setFillColor(typePalette[tempPoke.type1]);
     circle.setNoStroke();
     pokeCircle.add(circle);
     pokeWorld.add(circle);
   }
}
void sdefCircle(){
  pokeWorld.clear();
     pokeCircle = new ArrayList();
   for(int i =0; i<450; i++){
     PokemonPoint tempPoke;
     tempPoke = pokemon.get(i);
     FCircle circle = new FCircle(tempPoke.sdef/2);
     circle.setPosition(width/2+random(-300,300),height/2+random(-400,100));
     circle.setFillColor(typePalette[tempPoke.type1]);
     circle.setNoStroke();
     pokeCircle.add(circle);
     pokeWorld.add(circle);
   }
}
void spdCircle(){
   pokeWorld.clear();
     pokeCircle = new ArrayList();
   for(int i =0; i<450; i++){
     PokemonPoint tempPoke;
     tempPoke = pokemon.get(i);
     FCircle circle = new FCircle(tempPoke.spd/2);
     circle.setPosition(width/2+random(-300,300),height/2+random(-400,100));
     circle.setFillColor(typePalette[tempPoke.type1]);
     circle.setNoStroke();
     pokeCircle.add(circle);
     pokeWorld.add(circle);
   }
}

void controlEvent(ControlEvent theEvent){
  if(theEvent.isFrom(statBox)){
        if(statBox.getArrayValue()[0] == 1){
          hpCircle();
        }
        else if(statBox.getArrayValue()[1] == 1){
          atkCircle();
        }
          else if(statBox.getArrayValue()[2] == 1){
          defCircle();
        }
          else if(statBox.getArrayValue()[3] == 1){
          satkCircle();
        }
          else if(statBox.getArrayValue()[4] == 1){
          sdefCircle();
        }
          else if(statBox.getArrayValue()[5] == 1){
          spdCircle();
        }
  }
}


void fillPokemonArray() {
  String statsLine;
  String [] statsPieces;
  String pokemonLine;
  String [] pokemonPieces;
  String typeLine;
  String [] typePieces;
  String speciesLine;
  String [] speciesPieces;
  int typecount = 0;
  int currentId = 0;

  // temp values
  String t_name;
  int t_id, t_hp, t_atk, t_def, t_satk, t_sdef, t_spd, t_t1, t_t2, t_hab, t_cap;
  t_id = 0;
  t_t1 = 0;
  t_t2 = 0;
  // skip first line
  pokemonReader = createReader ("pokemon.csv");
  try {
    pokemonReader.readLine();
    pokemonLine = pokemonReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    pokemonLine = null;
  }

  // skip first line
  typeReader = createReader ("pokemon_types.csv");
  try {
    typeReader.readLine();
    typeLine = typeReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    typeLine = null;
  }

  // skip first line
  statsReader = createReader ("pokemon_stats.csv");
  try {
    statsReader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    statsLine = null;
  }

  while (t_id < 719/*pokemonLine != null*/) {
    pokemonPieces = split(pokemonLine, ",");
    t_id++;
    t_name = pokemonPieces[1];
    println(t_name);

    typePieces = split(typeLine, ",");
    while (t_id == Integer.parseInt (typePieces[0])) {
      typecount++;
      if (typecount == 1)
        t_t1 = Integer.parseInt(typePieces[1]);
      else if (typecount == 2)
        t_t2 = Integer.parseInt(typePieces[1]);
      try {
        typeLine = typeReader.readLine();
      }
      catch (IOException e) {
        e.printStackTrace();
        typeLine = null;
      }
      typePieces = split(typeLine, ",");
    }

    // do this for each stat
    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ",");  //reads a line
    t_hp = Integer.parseInt(statsPieces[2]); //takes hp stat

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ","); //takes next line
    t_atk = Integer.parseInt(statsPieces[2]); //takes atk 

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ","); //takes next line
    t_def = Integer.parseInt(statsPieces[2]); //takes def

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }
    statsPieces = split(statsLine, ","); //takes next line
    t_satk = Integer.parseInt(statsPieces[2]); //takes satk

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }    
    statsPieces = split(statsLine, ","); //takes next line
    t_sdef = Integer.parseInt(statsPieces[2]); //takes sdef

    try {
      statsLine = statsReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      statsLine = null;
    }    
    statsPieces = split(statsLine, ","); //takes next line
    t_spd = Integer.parseInt(statsPieces[2]); //takes spd

    if (typecount == 1)
      pokemon.add(new PokemonPoint(t_name, t_id, t_hp, t_atk, t_def, t_satk, t_sdef, t_spd, t_t1));
    else if (typecount == 2)
      pokemon.add(new PokemonPoint(t_name, t_id, t_hp, t_atk, t_def, t_satk, t_sdef, t_spd, t_t1, t_t2));

    typecount = 0;
    try {
      pokemonLine = pokemonReader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      pokemonLine = null;
    }
  }
}
}

