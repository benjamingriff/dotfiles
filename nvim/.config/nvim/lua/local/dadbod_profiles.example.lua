return {
  ["redshift-dev"] = {
    url = "postgresql://db_user@127.0.0.1:4000/dev?sslmode=require",
    password_ref = "op://Private/redshift-dev/password",
  },
  ["pep-brains"] = {
    url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
    password_ref = "op://Private/pep-brains/password",
  },
  ["dashboard-prod"] = {
    url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
    password_ref = "op://Private/dashboard-prod/password",
  },
}
