return {
  ["redshift-dev"] = {
    url = "postgresql://db_user@127.0.0.1:4000/dev?sslmode=require",
  },
  ["pep-brains"] = {
    url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
  },
  ["us-dash"] = {
    url = "postgresql://db_user@db.example.internal:5432/postgres?sslmode=require",
  },
  ["dashboard-prod"] = {
    url = "postgresql://db_user@db.example.internal:5432/app_db?sslmode=require",
  },
}
