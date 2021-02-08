//
//  BattleViewController.swift
//  TechMon
//
//  Created by 伊藤愛結 on 2021/02/08.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHpLabel: UILabel!
    @IBOutlet var playerMpLabel: UILabel!
    @IBOutlet var playerTpLabel: UILabel!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHpLabel: UILabel!
    @IBOutlet var enemyMpLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var playerHp = 100
    var playerMp = 0
    var enemyHp = 200
    var enemyMp = 0
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true
    
    var player: Character!
    var enemy: Character!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        playerHpLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMpLabel.text = "\(player.currentMP) / \(player.maxMP)"
        
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image
        enemyHpLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMpLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
        
        //ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
    
    @objc func updateGame(){
        player.currentMP += 1
        if player.currentMP >= player.maxMP{
            isPlayerAttackAvailable = true
            player.currentMP = player.maxMP
        }else{
            isPlayerAttackAvailable = false
        }
        
        enemy.currentMP += 1
        if enemy.currentMP >= enemy.maxMP{
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
    }
    
    func updateUI(){
        playerHpLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMpLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTpLabel.text = "\(player.currentTP) / \(player.maxTP)"
        
        enemyHpLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMpLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    func enemyAttack(){
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        
        judgeButtle()
    }
    
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool){
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！"
        }else{
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title:"バトル終了", message:finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func attackAction(){
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP{
                player.currentTP = player.maxTP
            }
            
            
            player.currentMP = 0
            
            judgeButtle()
            
        }
    }
    
    func judgeButtle(){
        if player.currentHP <= 0{
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }else if enemy.currentHP <= 0{
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    @IBAction func tameruAction(){
        
        if isPlayerAttackAvailable{
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP{
                player.currentTP = player.maxTP
            }
            player.currentMP = 0
        }

    }
    
    @IBAction func fireAction(){
        if isPlayerAttackAvailable && player.currentTP >= 40{
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            player.currentTP -= 40
            if player.currentTP <= 0{
                player.currentTP = 0
            }
            player.currentMP = 0
            judgeButtle()
        }
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
