resource "kubernetes_deployment" "wordpress" { 

  metadata { 

    name      = "wordpress" 

    namespace = "default" 

  } 

  spec { 

    replicas = 1 

    selector { 

      match_labels = { 

        app = "wordpress" 

      } 

    } 

    template { 

      metadata { 

        labels = { 

          app = "wordpress" 

        } 

      } 

      spec { 

        container { 

          image = "wordpress:${var.wordpress_tag}" 

          name  = "wordpress" 

          port { 

            container_port = 80 

          } 

          env { 

            name = "WORDPRESS_DB_HOST" 

            value = module.db.db_instance_address 

          } 

          env { 

            name = "WORDPRESS_DB_PASSWORD" 

            value = module.db.db_instance_password 

          } 

          env { 

            name = "WORDPRESS_DB_USER" 

            value = module.db.db_instance_username 

          } 

        } 

      } 

    } 

  } 

} 

 

resource "kubernetes_service" "wordpress" { 

  metadata { 

    name      = "wordpress" 

    namespace = "default" 

  } 

  spec { 

    selector = { 

      app = kubernetes_deployment.wordpress.spec.0.template.0.metadata.0.labels.app 

    } 

    type = "ClusterIP" 

    port { 

      port        = 80 

      target_port = 80 

    } 

  } 

} 