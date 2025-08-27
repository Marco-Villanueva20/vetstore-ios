//
//  SceneDelegate.swift
//  vet store
//
//  Created by Jacktter on 22/08/25.
//

import UIKit
import Supabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let supabase = SupabaseManager.shared.client
    
    func checkUserLoggedIn() async -> Bool {
        do {
            // Esto intenta recuperar la sesión del servidor
            let session = try await supabase.auth.session
            let user = session.user
            print("Usuario logueado: \(user.email ?? "sin email")")
            return true
        } catch {
            // Si no hay sesión o cualquier error
            print("No hay usuario logueado o error: \(error)")
            return false
        }
    }
    // Función para crear tu TabBar con 3 pestañas
        func createTabBarController(storyboard: UIStoryboard) -> UITabBarController {
            let homeVC = storyboard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
            homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
            let nav1 = UINavigationController(rootViewController: homeVC)
            
            let pedidosVC = storyboard.instantiateViewController(identifier: "PedidosViewController") as! PedidosViewController
            pedidosVC.tabBarItem = UITabBarItem(title: "Pedidos", image: UIImage(systemName: "cart.fill"), tag: 1)
            let nav2 = UINavigationController(rootViewController: pedidosVC)
            
            let clientesVC = storyboard.instantiateViewController(identifier: "ReviewViewController") as! ReviewViewController
            clientesVC.tabBarItem = UITabBarItem(title: "Reseñas", image: UIImage(systemName: "person.2.fill"), tag: 2)
            let nav3 = UINavigationController(rootViewController: clientesVC)
            
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [nav1, nav2, nav3]
            return tabBarController
        }



    

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
                window = UIWindow(windowScene: windowScene)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                // Verifica usuario async
                Task {
                    let loggedIn = await checkUserLoggedIn()
                    
                    if loggedIn {
                        window?.rootViewController = createTabBarController(storyboard: storyboard)
                    } else {
                        let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                        let navLogin = UINavigationController(rootViewController: loginVC)
                        window?.rootViewController = navLogin
                    }
                    
                    window?.makeKeyAndVisible()
                }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

