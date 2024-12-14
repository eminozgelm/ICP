import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import List "mo:base/List";
import Text "mo:base/Text";
import Result "mo:base/Result";


actor {

  public type SuperHeroID = Nat32;

    public type SuperHero  = {
      name : Text;
      superpowers: List.List<Text>;

    };

  private stable var next : SuperHeroID = 0;


  private stable var superheroes : Trie.Trie<SuperHeroID, SuperHero> = Trie.empty();

  public func CreateHero(newHero: SuperHero) : async Nat32{
    let id = next;
    next+=1;
    superheroes := Trie.replace(
      superheroes,
      key(id),
      Nat32.equal,
      ?newHero
    ).0;


    id



  };

  private func getHero(id: SuperHeroID) : async ?SuperHero {
    let result = Trie.find(
      superheroes,
      key(id),
      Nat32.equal
    );

    result
  };

  public func updateHero(id: SuperHeroID, newHero: SuperHero) : async Bool {
    let result = Trie.find(
      superheroes,
      key(id),
      Nat32.equal
    );

    let exists = Option.isSome(result);
    
    if(exists){
      superheroes := Trie.replace(
      superheroes,
      key(id),
      Nat32.equal,
      ?newHero
    ).0;
    };
    
    exists
  };

  public func delete(id: SuperHeroID) : async Bool {
    let result = Trie.find(
      superheroes,
      key(id),
      Nat32.equal
    );

    let exists = Option.isSome(result);
    
    if(exists){
      superheroes := Trie.replace(
      superheroes,
      key(id),
      Nat32.equal,
      null
    ).0;
    };
    
    exists
  };  

  private func key (x: SuperHeroID): Trie.Key<SuperHeroID> {

    {hash = x;
    key = x };

  };
  
  


};

