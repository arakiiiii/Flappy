//
//  GameScene.swift
//  Flappy
//
//  Created by Akira Kamite on 2019/01/04.
//  Copyright © 2019 araki. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var bird: SKSpriteNode!
    var appleNode: SKSpriteNode!
    
    //    衝突判定カテゴリー
    let birdCategory : UInt32 = 1 << 0
    let groudCategory : UInt32 = 1 << 1
    let wallCategory : UInt32 = 1 << 2
    let scoreCategory : UInt32 = 1 << 3
    
    
    //    スコア
    var score = 0
    var scoreLabelNode :SKLabelNode!
    var bestScoreLabelNode : SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //    SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //        重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
        physicsWorld.contactDelegate = self
        
        //        背景色を表示
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        //        スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //        壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        
        //        雲と地面と壁をはりつける
        setupGround()
        setupCloud()
        setupwall()
        setupBird()
        setupScoreLabel()
        //        setupApple()
        
    }
    
    
    //    地面の動きのまとまり
    func setupGround() {
        
        //        地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest  //処理速度を上げる
        
        //        必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //        スクロールするアクションを作成
        //        左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5.0)
        
        //        元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0.0)
        
        //        左にスクロール→元の位置→左にスクロールでも無限に切り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //        groundのスプライトを配置する
        for i in 0..<needNumber {
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //            スプライトの表示する位置を設定
            sprite.position = CGPoint(
                x: groundTexture.size().width * (CGFloat(i) + 0.5),
                y: groundTexture.size().height * 0.5
            )
            
            //            スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //            衝突カテゴリーを追加
            sprite.physicsBody?.categoryBitMask = groudCategory
            
            //            衝突時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            //            スプライトにアクションを設定
            sprite.run(repeatScrollGround)
            
            //            スプライトを追加
            scrollNode.addChild(sprite)
        }
    }
    
    //    雲の動きのまとまり
    func setupCloud() {
        
        //        雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //        必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //        スクロールするアクションを作成
        //        左方向に画像一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 5.0)
        
        //        元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        
        //        左にスクロール→元の位置→左にスクロールでも無限に切り替えるアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //        スプライトを配置する
        for i in 0..<needCloudNumber {
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100
            
            //            スプライトの表示する位置を設定
            sprite.position = CGPoint(
                x: cloudTexture.size().width * (CGFloat(i) + 0.5),
                y: self.size.height - cloudTexture.size().height * 0.5
            )
            
            //            スプライトにアクションを設定
            sprite.run(repeatScrollCloud)
            
            //                スプライトを追加
            scrollNode.addChild(sprite)
            
        }
    }
    
    //    アイテムのまとまり
    func setupApple() {
        
        //        りんごの画像を読み込む
        let appleTexture = SKTexture(imageNamed: "apple")
        appleTexture.filteringMode = .linear
        
        //        移動する距離を設定
        let movingAppleDistance = CGFloat(self.frame.size.width + appleTexture.size().width)
        
        //        画面外まで移動するアクションを設定
        let moveapple = SKAction.moveBy(x: -movingAppleDistance, y: 0, duration: 4.0)
        
        //        自身を取り除くアクションを作成
        let removeapple = SKAction.removeFromParent()
        
        //        二つのアクションを順に実行するアクションを作成
        let appleAnimation = SKAction.sequence([moveapple, removeapple])
        
        //        りんごを生成するアクションを作成
        let createAppleAnimation = SKAction.run({
            //            りんご関連のノードをのせるノードを作成
            let apple = SKNode()
            apple.position = CGPoint(x: self.frame.size.width, y: 0.0)
            apple.zPosition = -50.0
            
            //            1〜frame.heightまでのランダムな整数を設定
            let random_apple_y = arc4random_uniform(UInt32(self.frame.size.height))
            
            //            y座標を決定
            let apple_y = CGFloat(random_apple_y)
            
            
            let createApple = SKSpriteNode(texture: appleTexture)
            createApple.position = CGPoint(x: 0.0, y: apple_y)
            
            apple.addChild(createApple)
            
            apple.run(appleAnimation)
            
        })
        
        //        次のリンゴまでの待ち時間を設定
        let waitAppleAnimation = SKAction.wait(forDuration: 5.0)
        
        //        りんごの生成→待ち時間→りんごの生成を無限に繰り替えるアクションを作成
        let repeatForeverAppleAnimation = SKAction.repeatForever(SKAction.sequence([createAppleAnimation, waitAppleAnimation]))
        
        appleNode.run(repeatForeverAppleAnimation)
        
    }
    
    //    壁のまとまり
    func setupwall() {
        
        //        壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .nearest
        
        //        移動する距離を設定
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //        画面外まで移動するアクションを作成
        let movewall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4.0)
        
        //        自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //        2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([movewall, removeWall])
        
        //        壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            //            壁関連のノードをのせるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            wall.zPosition = -50.0  // 雲より手前で地面より奥
            
            //            画面y軸の中央値
            let center_y = self.frame.size.height / 2
            //            壁のy座標を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.size.height / 4
            //            下の壁のy軸の下限
            let underwall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 - random_y_range / 2)
            //            1〜random_y_rangeまでのランダムな整数の生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            //            y軸の下限にランダムな値を足して、下の壁のy座標を決定
            let under_wall_y = CGFloat(underwall_lowest_y + random_y)
            
            //            キャラが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            //            下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            
            wall.addChild(under)
            
            //            スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //            衝突時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            //            上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            wall.addChild(upper)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
            
            //            スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //            衝突時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            
            //            スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            //
            
        })
        
        //        次の壁生成までの待ち時間アクションを生成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //        壁を作成→待ち時間→壁を作成を無限に繰り返しするアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    }
    
    //    鳥のまとまり
    func setupBird(){
        //        鳥の画像を二種類取り込む
        let birdTexstureA = SKTexture(imageNamed: "bird_a")
        birdTexstureA.filteringMode = .linear
        let birdTexstureB = SKTexture(imageNamed: "bird_b")
        birdTexstureB.filteringMode = .linear
        
        //        二種類のテクスチャを交互に変更するメソッド
        let TexturesAnimation = SKAction.animate(with: [birdTexstureA, birdTexstureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(TexturesAnimation)
        
        //        スプライトを作成
        bird = SKSpriteNode(texture: birdTexstureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //        鳥に物理演算を設定する
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //        衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //        衝突のカテゴリーを設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groudCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groudCategory | wallCategory
        
        //        アニメーションを設定
        bird.run(flap)
        
        //        スプライトを設定
        addChild(bird)
        
    }
    
    //    画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0 {
            
            //        鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            //        鳥の縦方向に力を加える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            
        }else if bird.speed == 0 {
            restart()
        }
    }
    
    //    衝突時に呼ばれるカテゴリー
    func didBegin(_ contact: SKPhysicsContact) {
        //        ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0{
            return
        }
        
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //            スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //            ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST")
            if score > bestScore {
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore, forKey: "BEST")
                userDefaults.synchronize()
            }
            
        }else{
            //            壁か地面に衝突した
            print("GameOver")
            
            //            スクロールを停止させる
            scrollNode.speed = 0
            
            bird.physicsBody?.collisionBitMask = groudCategory
            
            let roll = SKAction.rotate(byAngle: (CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01), duration: 1)
            bird.run(roll, completion:{
                self.bird.speed = 0
            })
            
            
        }
        
    }
    
    //    リスタートするやつ
    func restart(){
        score = 0
        scoreLabelNode.text = String("Score:\(score)")
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groudCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        scrollNode.speed = 1
    }
    
    //    スコアラベルのまとまり
    func setupScoreLabel() {
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
}
