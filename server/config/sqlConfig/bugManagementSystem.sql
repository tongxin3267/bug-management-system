USE [master]
GO
/****** Object:  Database [BugManagementSystem]    Script Date: 2018/6/8 11:26:55 ******/
CREATE DATABASE [BugManagementSystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'BugManagementSystem', FILENAME = N'D:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\bug-management-system.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'BugManagementSystem_log', FILENAME = N'D:\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\bug-management-system_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [BugManagementSystem] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BugManagementSystem].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [BugManagementSystem] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BugManagementSystem] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BugManagementSystem] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BugManagementSystem] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BugManagementSystem] SET ARITHABORT OFF 
GO
ALTER DATABASE [BugManagementSystem] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BugManagementSystem] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BugManagementSystem] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BugManagementSystem] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BugManagementSystem] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BugManagementSystem] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BugManagementSystem] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BugManagementSystem] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BugManagementSystem] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BugManagementSystem] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BugManagementSystem] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BugManagementSystem] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BugManagementSystem] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BugManagementSystem] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BugManagementSystem] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BugManagementSystem] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BugManagementSystem] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BugManagementSystem] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [BugManagementSystem] SET  MULTI_USER 
GO
ALTER DATABASE [BugManagementSystem] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BugManagementSystem] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BugManagementSystem] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BugManagementSystem] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [BugManagementSystem] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [BugManagementSystem] SET QUERY_STORE = OFF
GO
USE [BugManagementSystem]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [BugManagementSystem]
GO
/****** Object:  User [mgmt-admin]    Script Date: 2018/6/8 11:26:55 ******/
CREATE USER [mgmt-admin] FOR LOGIN [mgmt-admin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [mgmt-admin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [mgmt-admin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [mgmt-admin]
GO
/****** Object:  Table [dbo].[issue]    Script Date: 2018/6/8 11:26:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[issue](
	[id] [char](13) NOT NULL,
	[title] [nchar](30) NOT NULL,
	[issueSelect] [nchar](10) NOT NULL,
	[severity] [tinyint] NOT NULL,
	[version] [char](10) NOT NULL,
	[project] [char](13) NOT NULL,
	[module] [char](30) NULL,
	[text] [ntext] NOT NULL,
	[issuer] [char](10) NOT NULL,
	[dispense] [char](10) NULL,
	[developer] [char](10) NULL,
	[tester] [char](10) NULL,
	[priority] [tinyint] NOT NULL,
	[versionEnd] [char](10) NULL,
	[startDate] [datetime] NOT NULL,
	[endDate] [datetime] NULL,
	[status] [tinyint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[module]    Script Date: 2018/6/8 11:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[module](
	[id] [char](14) NOT NULL,
	[title] [nchar](30) NOT NULL,
	[pid] [char](14) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[permission]    Script Date: 2018/6/8 11:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[permission](
	[userId] [int] NOT NULL,
	[projectId] [char](13) NOT NULL,
	[permission] [char](6) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[project]    Script Date: 2018/6/8 11:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[project](
	[id] [char](13) NOT NULL,
	[title] [nchar](30) NOT NULL,
	[share] [bit] NOT NULL,
	[projectDesc] [ntext] NULL,
	[imgName] [nchar](15) NULL,
	[status] [tinyint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[solution]    Script Date: 2018/6/8 11:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[solution](
	[id] [char](13) NOT NULL,
	[issueId] [char](13) NOT NULL,
	[issueName] [nchar](30) NOT NULL,
	[solveDesc] [ntext] NOT NULL,
	[testDesc] [ntext] NULL,
	[isClose] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user]    Script Date: 2018/6/8 11:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user](
	[userId] [int] IDENTITY(1000000000,1) NOT NULL,
	[userName] [nchar](30) NOT NULL,
	[userPwd] [nchar](30) NOT NULL,
	[userEmail] [nchar](50) NULL,
	[userAvatar] [ntext] NULL,
	[userDesc] [ntext] NULL,
	[userStatus] [tinyint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[version]    Script Date: 2018/6/8 11:26:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[version](
	[id] [int] IDENTITY(1000000000,1) NOT NULL,
	[sortId] [int] NULL,
	[title] [nchar](20) NOT NULL,
	[versionDesc] [ntext] NULL,
	[pid] [char](13) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
USE [master]
GO
ALTER DATABASE [BugManagementSystem] SET  READ_WRITE 
GO
